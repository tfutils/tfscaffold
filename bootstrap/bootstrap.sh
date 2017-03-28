#!/bin/bash
set -e

# Determine where I am and from that derive basepath and project name
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
base_path="${script_path%%\/bootstrap}";
default_project_name="${base_path##*\/}";

# Standardised failure function
function error_and_die {
  echo -e "ERROR: ${1}" >&2;
  exit 1;
};

function usage() {
cat <<EOF
Usage: ${0} \\
  -p/--project       [project]
  -b/--bucket-prefix [bucket_prefix] (optional) \\
  -r/--region        [region]        (optional if AWS_DEFAULT_REGION set)
  -h/--help

project:
 - the name of the project to have a terraform bootstrap applied

bucket_prefix (optional):
 Defaults to: "\${project}-terraformscaffold" 
 Alternative examples:
 - myproject-terraform
 - terraform-yourproject
 - my-first-terraform-project

region (optional):
 Defaults to value of \$AWS_DEFAULT_REGION
 - the AWS region name unique to all components and terraform processes

EOF
};

# Ensure script console output is separated by blank line at top and bottom to improve readability
trap echo EXIT;
echo;

# Execute getopt
ARGS=$(getopt \
         -o b:r:hp: \
         -l "bucket-prefix:,region:,help,project:" \
         -n "${0}" \
         -- \
         "$@");

#Bad arguments
if [ $? -ne 0 ]; then
  usage;
  error_and_die "command line argument parse failure";
fi;

eval set -- "${ARGS}";

declare region_arg;
declare bucket_prefix;
declare project;

while true; do
  case "${1}" in
    -h|--help)
      usage;
      exit 0;
      ;;
    -r|--region)
      shift;
      if [ -n "${1}" ]; then
        region_arg="${1}";
        shift;
      fi;
      ;;
    -b|--bucket-prefix)
      shift;
      if [ -n "${1}" ]; then
        bucket_prefix="${1}";
        shift;
      fi;
      ;;
    -p|--project)
      shift;
      if [ -n "${1}" ]; then
        project="${1}";
        shift;
      fi;
      ;; 
    --)
      shift;
      break;
      ;;
  esac;
done;

readonly region="${region_arg:-${AWS_DEFAULT_REGION}}";
[ -n "${region}" ] \
  || error_and_die "No AWS region specified. No -r/--region argument supplied and AWS_DEFAULT_REGION undefined";

[ -n "${project}" ] \
  || error_and_die "No project specified.";

# Validate AWS Credentials Available
iam_iron_man="$(aws iam get-user --output text --query 'User.Arn')";
if [ -n "${iam_iron_man}" ]; then
  echo -e "AWS Credentials Found. Using ARN '${iam_iron_man}'";
else
  error_and_die "No AWS Credentials Found. 'aws iam get-user' responded with ARN '${iam_iron_man}'";
fi;

# Query canonical AWS Account ID
aws_account_id="$(aws ec2 describe-security-groups --query 'SecurityGroups[0].OwnerId' --output text)";
if [ -n "${aws_account_id}" ]; then
  echo -e "AWS Account ID: ${aws_account_id}";
else
  error_and_die "Couldn't determine AWS Account ID";
fi;

if [ -n "${bucket_prefix}" ]; then
  readonly bucket="${bucket_prefix}-${aws_account_id}-${region}"
  echo -e "Using S3 bucket s3://${bucket}";
else
  readonly bucket="${project}-terraformscaffold-${aws_account_id}-${region}";
  echo -e "No bucket prefix specified. Using S3 bucket s3://${bucket}";
fi;

(
  [ "$(pwd)" == "${script_path}" ] || cd ${script_path};

  # Create bootstrap bucket
  terraform apply \
    -var "region=${region}" \
    -var "project=${project}" \
    -var "bucket_name=${bucket}" \
    -var "aws_account_id=${aws_account_id}" \
    || error_and_die "Terraform apply failed";

  # Really Hashicorp? Really?!
  #
  # In order to work with terraform >=0.9.2 (I say 0.9.2 because 0.9 prior
  # to 0.9.2 is barely usable due to key bugs and missing features)
  # we now need to do some ugly things to our terraform remote backend configuration.
  # The long term hope is that they will fix this, and maybe remove the need for it
  # altogether by supporting interpolation in the backend config stanza.
  #
  # For now we're left with this garbage, and no more support for <0.9.0.
  if [ -f backend_terraformscaffold.tf ]; then
    echo -e "WARNING: Overwriting backend_terraformscaffold.tf" >&2;
  fi;

  echo -e "terraform {
  backend \"s3\" {
    region = \"${region}\"
    bucket = \"${bucket}\"
    key    = \"${project}/${aws_account_id}/${region}/${environment}/${component_name}.tfstate\"
  }
}" > backend_terraformscaffold.tf \
  || error_and_die "Failed to write backend config to $(pwd)/backend_terraformscaffold.tf";

  # Push Terraform Remote State to S3
  terraform remote push \
    || error_and_die "Terraform remote push failed";

  rm -f backend_terraformscaffold.tf
) || exit $?;

