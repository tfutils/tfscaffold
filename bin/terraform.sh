#!/bin/bash
# Terraform Scaffold
#
# A wrapper for running terraform projects
# - handles remote state
# - uses consistent .tfvars files for each environment

# Standardised failure function
function error_and_die {
  echo -e "ERROR: ${1}" >&2;
  exit 1;
};

# Determine where I am and from that derive basepath and project name
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
base_path="${script_path%%\/bin}";
project_name_default="${base_path##*\/}";

status=0;

echo "Args " $*;

function usage() {

cat <<EOF
Usage: ${0} \\
  -a/--action        [action] \\
  -b/--bucket-prefix [bucket_prefix] \\
  -c/--component     [component_name] \\
  -e/--environment   [environment] \\
  -i/--build-id      [build_id] (optional) \\
  -p/--project       [project] \\
  -r/--region        [region] \\
  -- \\
  <additional arguments to forward to the terraform binary call>

action:
 - plan
 - apply
 - plan-destroy
 - destroy

bucket_prefix (optional):
 Defaults to: "\${project_name}-terraformscaffold"
 - myproject-terraform
 - terraform-yourproject
 - my-first-terraformscaffold-project

build_id (optional):
 - testing
 - \$BUILD_ID (jenkins)

component_name:
 - the name of the terraform component module in the components directory
  
environment:
 - dev
 - test
 - prod
 - management

project:
 - The name of the project being deployed

region (optional):
 Defaults to value of \$AWS_DEFAULT_REGION
 - the AWS region name unique to all components and terraform processes

additional arguments:
 Any arguments provided after "--" will be passed directly to terraform as its own arguments
EOF
};

# Ensure script console output is separated by blank line at top and bottom to improve readability
trap echo EXIT;
echo;

# Execute getopt
ARGS=$(getopt \
         -o a:b:c:e:i:p:r: \
         -l "action:,bucket-prefix:,build-id:,component:,environment:,project:,region:" \
         -n "${0}" \
         -- \
         "$@");

#Bad arguments
if [ $? -ne 0 ]; then
  usage;
  error_and_die "command line argument parse failure";
fi;

eval set -- "${ARGS}";

declare component_arg;
declare region_arg;
declare environment_arg;
declare action;
declare bucket_prefix;
declare build_id;
declare project;

while true; do
  case "${1}" in
    -c|--component)
      shift;
      if [ -n "${1}" ]; then
        component_arg="${1}";
        shift;
      fi;
      ;;
    -r|--region)
      shift;
      if [ -n "${1}" ]; then
        region_arg="${1}";
        shift;
      fi;
      ;;
    -e|--environment)
      shift;
      if [ -n "${1}" ]; then
        environment_arg="${1}";
        shift;
      fi;
      ;;
    -a|--action)
      shift;
      if [ -n "${1}" ]; then
        action="${1}";
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
    -i|--build-id)
      shift;
      if [ -n "${1}" ]; then
        build_id="${1}";
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

declare extra_args="${@}"; # All arguments supplied after "--"

# Set Region from args or environment. Exit if unset.
readonly region="${region_arg:-${AWS_DEFAULT_REGION}}";
[ -n "${region}" ] \
  || error_and_die "No AWS region specified. No -r/--region argument supplied and AWS_DEFAULT_REGION undefined";

[ -n "${project}" ] \
  || error_and_die "Required argument -p/--project not specified";

# Validate component to work with
[ -n "${component_arg}" ] \
  || error_and_die "Required argument missing: -c/--component";
readonly component="${component_arg}";

# Validate environment to work with
[ -n "${environment_arg}" ] \
  || error_and_die "Required argument missing: -e/--environment";
readonly environment="${environment_arg}";

[ -n "${action}" ] \
  || error_and_die "Required argument missing: -a/--action";

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

# Validate S3 bucket. Set default if undefined
if [ -n "${bucket_prefix}" ]; then
  readonly bucket="${bucket_prefix}-${aws_account_id}-${region}"
  echo -e "Using S3 bucket s3://${bucket}";
else
  readonly bucket="${project}-terraformscaffold-${aws_account_id}-${region}";
  echo -e "No bucket prefix specified. Using S3 bucket s3://${bucket}";
fi;

declare component_path="${base_path}/components/${component}";

# Get the absolute path to the component
if [[ "${component_path}" != /* ]]; then
  component_path="$(cd "$(pwd)/${component_path}" && pwd)";
else
  component_path="$(cd "${component_path}" && pwd)";
fi;

## Debug
#echo $component_path;

# Begin parameter-dependent logic
case "${action}" in
  apply)
    refresh="-refresh=true";
    ;;
  destroy)
    destroy='-destroy';
    force='-force';
    refresh="-refresh=true";
    ;;
  graph) ;;
  output) ;;
  plan) ;;
  plan-destroy)
    action="plan";
    destroy="-destroy";
    refresh="-refresh=true";
    ;;
  refresh) ;;
  show) ;;
  *)
    usage
    error_and_die "Invalid action parameter";
    ;;
esac;

# Clear the cached terraform state (we want to pull the state from the remote,
# and also it can be different per-env)
rm -rf ${component_path}/.terraform/terraform.tfstate*;

# Make sure we're running in the component directory
cd "${component_path}";

readonly component_name=$(basename ${component_path});

if [ -f "pre_apply.sh" ]; then
  bash pre_apply.sh "${region}" "${environment}" "${action}";
  ((status=status+"$?"));
fi;

# Pull down secret TFVAR file from S3
declare -a secrets=();
readonly secret_file_name="secret_${region}_${environment}.tfvars.enc";
aws s3 ls s3://${bucket}/${project}/secrets/${secret_file_name} >/dev/null 2>&1;
if [ $? -eq 0 ]; then
  mkdir -p build;
  aws s3 cp s3://${bucket}/${project}/secrets/${secret_file_name} build/${secret_file_name};
  if [ -f "build/${secret_file_name}" ]; then
    secrets=($(aws kms decrypt --ciphertext-blob fileb://build/${secret_file_name} --output text --query Plaintext | base64 --decode));
  fi;
fi;

if [ -n "${secrets[0]}" ]; then
  secret_regex='^[A-Za-z0-9_-]+=.+$';
  secret_count=1;
  for secret_line in "${secrets[@]}"; do
    if [[ "${secret_line}" =~ ${secret_regex} ]]; then
      var_key="${secret_line%=*}";
      var_val="${secret_line##*=}";
      # Better ways in bash4; but not wanting a bash4 dependency
      eval export TF_VAR_${var_key}="${var_val}";
      ((secret_count++));
    else
      echo "Malformed secret on line ${secret_count} - ignoring";
    fi;
  done;
fi;
    
# Use versions TFVAR files if exists
readonly versions_file_name="versions_${region}_${environment}.tfvars";
readonly versions_file_path="${base_path}/etc/${versions_file_name}";

# Check environment name is a known environment
# Could potentially support non-existent tfvars, but choosing not to.
readonly env_file_path="${base_path}/etc/env_${region}_${environment}.tfvars";
if [ ! -f "${env_file_path}" ]; then
  error_and_die "Unknown environment.  ${env_file_path} does not exist.";
fi;

# Build up the tfvars arguments for terraform command line
readonly mandatory_tfvars="-var-file=${env_file_path}";
if [ -f "${versions_file_path}" ]; then
  readonly optional_tfvars="${tf_var_files} -var-file=${versions_file_path}";
fi;
readonly tf_var_files="${mandatory_tfvars} ${optional_tfvars}";

# Configure remote state storage
echo "Setting up S3 remote state from s3://${bucket}/${project}/${aws_account_id}/${region}/${environment}/${component_name}.tfstate";
terraform remote config \
  -backend=s3 \
  -backend-config="region=${region}" \
  -backend-config="bucket=${bucket}" \
  -backend-config="key=${project}/${aws_account_id}/${region}/${environment}/${component_name}.tfstate" \
  || error_and_die "Terraform remote config failed";

# Fetch terraform modules into .terraform/modules
terraform get -update=true \
  || error_and_die "Terraform Get failed";

case "${action}" in
  'plan'*)
    if [ -n "${build_id}" ]; then
      mkdir -p build;

      plan_file_name="${component_name}_${build_id}.tfplan";
      plan_file_remote_key="${project}/${aws_account_id}/${region}/${environment}/plans/${plan_file_name}";

      out="-out=build/${plan_file_name}";
    fi;

    terraform "${action}" \
      -input=false \
      ${refresh} \
      -module-depth=-1 \
      ${tf_var_files} \
      ${extra_args} \
      ${destroy} \
      ${out} \
      || error_and_die "Terraform plan failed";

    if [ -n "${build_id}" ]; then
      aws s3 cp build/${plan_file_name} s3://${bucket}/${plan_file_remote_key} \
        || error_and_die "Plan file upload to S3 failed (s3://${bucket}/${plan_file_remote_key})";
    fi;

    exit ${status};
    ;;
  'show')
    terraform show;
    exit $?;
    ;;
  'output')
    # Show Output variables
    terraform output;
    exit $?;
    ;;
  'graph')
    mkdir -p build;
    terraform graph -draw-cycles | dot -Tpng > ${module_name}-diagram.png;
    echo Generated: build/${module_name}-diagram.png;
    terraform graph -draw-cycles -verbose | dot -Tpng > build/${module_name}-diagram-verbose.png;
    echo Generated: build/${module_name}-diagram-verbose.png;
    exit $?;
    ;;
  'apply'|'destroy')
    if [ -n "${build_id}" ]; then
      mkdir -p build;
      plan_file_name="${component_name}_${build_id}.tfplan";
      plan_file_remote_key="${project}/${aws_account_id}/${region}/${environment}/plans/${plan_file_name}";

      aws s3 cp s3://${bucket}/${plan_file_remote_key} build/${plan_file_name} \
        || error_and_die "Plan file download from S3 failed (s3://${bucket}/${plan_file_remote_key})";

      apply_plan="build/${plan_file_name}";

      terraform "${action}" \
        -input=false \
        ${refresh} \
        -parallelism=10 \
        ${extra_args} \
        ${force} \
        ${apply_plan};
      exit_code=$?;
    else
      terraform "${action}" \
        -input=false \
        ${refresh} \
        ${tf_var_files} \
        -parallelism=10 \
        ${extra_args} \
        ${force};
      exit_code=$?;
    fi;

    # Let's just be sure...
    terraform remote push;

    if [ ${exit_code} -ne 0 ]; then
      error_and_die "Terraform ${action} failed with exit code ${exit_code}"
    fi;

    if [ -f "post_apply.sh" ]; then
      bash post_apply.sh "${region}" "${environment}" "${action}";
      exit $?;
    fi
    ;;
  *)
    error_and_die "U WOT M8?";
    ;;
esac;

exit 0;
