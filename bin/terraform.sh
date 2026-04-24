#!/usr/bin/env bash
# Terraform Scaffold
#
# A wrapper for running terraform projects
# - handles remote state
# - uses consistent .tfvars files for each environment

set -uo pipefail;

##
# Terraform Binary
##
readonly terraform_bin="${TERRAFORM_BIN:-terraform}";

##
# Set Script Version
##
readonly script_ver='2.3.0';

##
# Standardised failure function
##
function error_and_die {
  printf '[ERROR] %b\n' "${1}" >&2;
  exit "${2:-1}";
};

##
# Print Script Version
##
function version() {
  echo "${script_ver}";
}

##
# Print Usage Text
##
function usage() {

cat <<EOF
Usage: ${0} \\
  -a/--action        [action] \\
  -b/--bucket-prefix [bucket_prefix] \\
  -c/--component     [component_name] \\
  -e/--environment   [environment] \\
  -g/--group         [group] (optional, comma-delimited for multiple) \
  -i/--build-id      [build_id] (optional) \\
  -l/--lockfile      [mode] \\
  -p/--project       [project] \\
  -r/--region        [region] \\
  -d/--detailed-exitcode \\
  -j/--disable-output-json \\
  -n/--no-color \\
  -t/--lock-table \\
  -w/--compact-warnings \\
  -- \\
  <additional arguments to forward to the terraform binary call>

action:
 - Special actions:
    * plan / plan-destroy
    * apply / destroy
    * graph
    * taint / untaint
    * shell
- Generic actions:
    * See https://www.terraform.io/docs/commands/

bucket_prefix (optional):
 Defaults to: "\${project_name}-tfscaffold"
 - myproject-terraform
 - terraform-yourproject
 - my-first-tfscaffold-project

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

group (optional):
 Supports comma-delimited values for multiple groups, e.g. "dev,live"
 - dev
 - live
 - mytestgroup
 - dev,live

project:
 - The name of the project being deployed

region (optional):
 Defaults to value of \$AWS_DEFAULT_REGION
 - the AWS region name unique to all components and terraform processes

detailed-exitcode (optional):
 When not provided, false.
 Changes the plan operation to exit 0 only when there are no changes.
 Will be ignored for actions other than plan.

lock-table (optional):
  When not provided, false.
  Adds a dynamodb_table statement to the S3 backend configuration
  to use a DynamoDB table with the same name as the S3 bucket
  for terraform state locking.

no-color (optional):
 Append -no-color to all terraform calls

compact-warnings (optional):
 Append -compact-warnings to all terraform calls

disable-output-json (optional):
 Don't write outputs to the .terraform.output.json file

lockfile:
 Append -lockfile=MODE to calls to terraform init

additional arguments:
 Any arguments provided after "--" will be passed directly to terraform as its own arguments
EOF
};

##
# Test for GNU getopt
##
getopt_out=$(getopt -T);
if (( $? != 4 )) && [[ -n $getopt_out ]]; then
  error_and_die "Non GNU getopt detected. If you're using a Mac then try \"brew install gnu-getopt\"";
fi

##
# Execute getopt and process script arguments
##
readonly raw_arguments="${*}";
ARGS=$(getopt \
         -o dhjntvwa:b:c:e:g:i:l:p:r: \
         -l 'help,version,bootstrap,action:,bucket-prefix:,build-id:,component:,environment:,group:,groups:,project:,region:,lockfile:,detailed-exitcode,lock-table,no-color,compact-warnings,disable-output-json' \
         -n "${0}" \
         -- \
         "${@}");

#Bad arguments
if [ "$?" -ne 0 ]; then
  usage;
  error_and_die 'command line argument parse failure';
fi;

eval set -- "${ARGS}";

declare bootstrap='false';
declare component_arg='';
declare region_arg='';
declare environment_arg='';
declare group='';
declare action='';
declare bucket_prefix='';
declare build_id='';
declare lockfile='';
declare project='';
declare detailed_exitcode='';
declare lock_table='';
declare no_color='';
declare compact_warnings='';
declare output_json='true';
declare out='';
declare destroy='';
declare refresh='';
declare detailed='';
declare force='';
declare apply_plan='';
declare destroy_response='';

while true; do
  case "${1}" in
    -h|--help)
      usage;
      exit 0;
      ;;
    -v|--version)
      version;
      exit 0;
      ;;
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
    -g|--group|--groups)
      shift;
      if [ -n "${1}" ]; then
        group="${1}";
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
    -l|--lockfile)
      shift;
      if [ -n "${1}" ]; then
        lockfile="-lockfile=${1}";
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
    --bootstrap)
      shift;
      bootstrap='true';
      ;;
    -d|--detailed-exitcode)
      shift;
      detailed_exitcode='true';
      ;;
    -j|--disable-output-json)
      shift;
      output_json='false';
      ;;
    -t|--lock-table)
      shift;
      lock_table='true';
      ;;
    -n|--no-color)
      shift;
      no_color="-no-color";
      ;;
    -w|--compact-warnings)
      shift;
      compact_warnings="-compact-warnings";
      ;;
    --)
      shift;
      break;
      ;;
  esac;
done;

declare extra_args="${@} ${no_color}"; # All arguments supplied after "--"

##
# Script Set-Up
##

# Determine where I am and from that derive basepath and project name
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
base_path="${script_path%%\/bin}";
project_name_default="${base_path##*\/}";

status=0;

echo "Args ${raw_arguments}";

# Ensure script console output is separated by blank line at top and bottom to improve readability
trap echo EXIT;
echo;

##
# Munge Params
##

# Set Region from args or environment. Exit if unset.
readonly region="${region_arg:-${AWS_DEFAULT_REGION:-}}";
[ -n "${region}" ] \
  || error_and_die 'No AWS region specified. No -r/--region argument supplied and AWS_DEFAULT_REGION undefined';

[ -n "${project}" ] \
  || error_and_die 'Required argument -p/--project not specified';

# Bootstrapping is special
if [ "${bootstrap}" == 'true' ]; then
  [ -n "${component_arg}" ] \
    && error_and_die 'The --bootstrap parameter and the -c/--component parameter are mutually exclusive';
  [ -n "${build_id}" ] \
    && error_and_die 'The --bootstrap parameter and the -i/--build-id parameter are mutually exclusive. We do not currently support plan files for bootstrap';
  [ -n "${environment_arg}" ] && readonly environment="${environment_arg}";
else
  # Validate component to work with
  [ -n "${component_arg}" ] \
    || error_and_die 'Required argument missing: -c/--component';
  readonly component="${component_arg}";

  # Validate environment to work with
  [ -n "${environment_arg}" ] \
    || error_and_die 'Required argument missing: -e/--environment';
  readonly environment="${environment_arg}";
fi;

[ -n "${action}" ] \
  || error_and_die 'Required argument missing: -a/--action';

# Validate AWS Credentials Available
iam_iron_man="$(aws sts get-caller-identity --query 'Arn' --output text)";
if [ -n "${iam_iron_man}" ]; then
  echo -e "AWS Credentials Found. Using ARN '${iam_iron_man}'";
else
  error_and_die "No AWS Credentials Found. \"aws sts get-caller-identity --query 'Arn' --output text\" responded with ARN '${iam_iron_man}'";
fi;

# Query canonical AWS Account ID
aws_account_id="$(aws sts get-caller-identity --query 'Account' --output text)";
if [ -n "${aws_account_id}" ]; then
  echo -e "AWS Account ID: ${aws_account_id}";
else
  error_and_die "Couldn't determine AWS Account ID. \"aws sts get-caller-identity --query 'Account' --output text\" provided no output";
fi;

# Export common variables for terraform consumption as lowest-precedence defaults.
# These will be overridden by any tfvars files or -var arguments.
export TF_VAR_aws_account_id="${aws_account_id}";
export TF_VAR_region="${region}";
[ -n "${environment:-}" ] && export TF_VAR_environment="${environment}";

# Validate S3 bucket. Set default if undefined
if [ -n "${bucket_prefix}" ]; then
  readonly bucket="${bucket_prefix}-${aws_account_id}-${region}";
  echo -e "Using S3 bucket s3://${bucket}";
else
  readonly bucket="${project}-tfscaffold-${aws_account_id}-${region}";
  echo -e "No bucket prefix specified. Using S3 bucket s3://${bucket}";
fi;

declare component_path='';
if [ "${bootstrap}" == 'true' ]; then
  component_path="${base_path}/bootstrap";
else
  component_path="${base_path}/components/${component}";
fi;

# Get the absolute path to the component
if [[ "${component_path}" != /* ]]; then
  component_path="$(cd "$(pwd)/${component_path}" && pwd)";
else
  component_path="$(cd "${component_path}" && pwd)";
fi;

[ -d "${component_path}" ] || error_and_die "Component path ${component_path} does not exist";

## Debug
#echo $component_path;

##
# Begin parameter-dependent logic
##

case "${action}" in
  apply)
    refresh='-refresh=true';
    ;;
  destroy)
    destroy='-destroy';
    refresh='-refresh=true';
    ;;
  plan)
    refresh='-refresh=true';
    ;;
  plan-destroy)
    action='plan';
    destroy='-destroy';
    refresh='-refresh=true';
    ;;
  *)
    ;;
esac;

# Tell terraform to moderate its output to be a little
# more friendly to automation wrappers
# Value is irrelavant, just needs to be non-null
export TF_IN_AUTOMATION='true';

for rc_path in "${base_path}" "${base_path}/etc" "${component_path}"; do
  if [ -f "${rc_path}/.terraformrc" ]; then
    echo "Found .terraformrc at ${rc_path}/.terraformrc. Overriding.";
    export TF_CLI_CONFIG_FILE="${rc_path}/.terraformrc";
  fi;
done;

# Configure the plugin-cache location so plugins are not
# downloaded to individual components
declare default_plugin_cache_dir="${base_path}/plugin-cache";
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${default_plugin_cache_dir}}";
mkdir -p "${TF_PLUGIN_CACHE_DIR}" \
  || error_and_die "Failed to created the plugin-cache directory (${TF_PLUGIN_CACHE_DIR})";
[ -w "${TF_PLUGIN_CACHE_DIR}" ] \
  || error_and_die "plugin-cache directory (${TF_PLUGIN_CACHE_DIR}) not writable";

# Clear cache, safe enough as we enforce plugin cache
rm -rf "${component_path}/.terraform";

# Run global pre.sh
if [ -f 'pre.sh' ]; then
  source pre.sh "${region}" "${environment}" "${action}" \
    || error_and_die "Global pre script execution failed with exit code ${?}";
fi;

# Make sure we're running in the component directory
pushd "${component_path}";
readonly component_name=$(basename "${component_path}");

# Check for presence of tfenv (https://github.com/kamatama41/tfenv)
# and a .terraform-version file. If both present, ensure required
# version of terraform for this component is installed automagically.
tfenv_bin="$(which tfenv 2>/dev/null)";
if [[ -n "${tfenv_bin}" && -x "${tfenv_bin}" && -f .terraform-version ]]; then
  ${tfenv_bin} install;
fi;

# Regardless of bootstrapping or not, we'll be using this string.
# If bootstrapping, we will fill it with variables,
# if not we will fill it with variable file parameters
declare tf_var_params='';

if [ "${bootstrap}" == 'true' ]; then
  if [ "${action}" == "destroy" ]; then
    echo -en "\n#####################\n# ALERT ALERT ALERT #\n#####################\n\nDo you *really* want to destroy this bootstrap?\n\nPerforming this action will delete your WHOLE STATE BUCKET (${bucket}) AND ALL ITS CONTENTS FOR ALL ENVIRONMENTS.\nAny state files you have created as part of this tfscaffold project will be IRRECOVERABLY DELETED! Forever!\n\nAcknowledge by typing out this exact sentence, removing all + characters: \"I+am+not+an+idiot,+I+know+what+I+am+doing!\": ";
    read destroy_response;
    if [ "${destroy_response}" != 'I am not an idiot, I know what I am doing!' ]; then
      error_and_die "ABORT ABORT ABORT!! YOU ARE AN IDIOT!!";
    fi;
  fi;

  # Bootstrap requires this parameter as explicit as it is constructed here
  # for multiple uses, so we cannot just depend on it being set in tfvars
  tf_var_params+=" -var bucket_name=${bucket}";
fi;

# Run component-specific pre.sh
if [ -f "pre.sh" ]; then
  source pre.sh "${region}" "${environment}" "${action}" \
    || error_and_die "Component pre script execution failed with exit code ${?}";
fi;

# Pull down secret TFVAR file from S3
# Anti-pattern and security warning: This secrets mechanism provides very little additional security.
# It permits you to inject secrets directly into terraform without storing them in source control or unencrypted in S3.
# Secrets will still be stored in all copies of your state file - which will be stored on disk wherever this script is run and in S3.
# This script does not currently support encryption of state files.
# Use this feature only if you're sure it's the right pattern for your use case.
declare -a secrets=();
readonly secrets_file_name='secret.tfvars.enc';
readonly secrets_file_path="build/${secrets_file_name}";
aws s3 ls "s3://${bucket}/${project}/${aws_account_id}/${region}/${environment}/${secrets_file_name}" >/dev/null 2>&1;
if [ "$?" -eq 0 ]; then
  mkdir -p build;
  aws s3 cp "s3://${bucket}/${project}/${aws_account_id}/${region}/${environment}/${secrets_file_name}" "${secrets_file_path}" \
    || error_and_die "S3 secrets file is present, but inaccessible. Ensure you have permission to read s3://${bucket}/${project}/${aws_account_id}/${region}/${environment}/${secrets_file_name}";
  if [ -f "${secrets_file_path}" ]; then
    secrets=($(aws kms decrypt --ciphertext-blob "fileb://${secrets_file_path}" --output text --query Plaintext | base64 --decode));
  fi;
fi;

if [ "${#secrets[@]}" -gt 0 ] && [ -n "${secrets[0]}" ]; then
  secret_regex='^[A-Za-z0-9_-]+=.+$';
  secret_count=1;
  for secret_line in "${secrets[@]}"; do
    if [[ "${secret_line}" =~ ${secret_regex} ]]; then
      var_key="${secret_line%=*}";
      var_val="${secret_line##*=}";
      export TF_VAR_${var_key}="${var_val}";
      ((secret_count++));
    else
      echo "Malformed secret on line ${secret_count} - ignoring";
    fi;
  done;
fi;

# Pull down any tfvars files from S3 to use with Terraform
# This supports multiple remote tfvars files (*.tfvars and *.tfvars.json)
# stored at the environment level in the state bucket.
# Anti-pattern warning: Your variables should almost always be in source control.
# There are a very few use cases where you need constant variability in input variables,
# and even in those cases you should probably pass additional -var parameters to this script
# from your automation mechanism.
# Use this feature only if you're sure it's the right pattern for your use case.
readonly remote_vars_path="s3://${bucket}/${project}/${aws_account_id}/${region}/${environment}/";
echo "Checking for remote tfvars files in ${remote_vars_path}";
readonly remote_vars="$(aws s3 ls "${remote_vars_path}" | grep -E '\.tfvars(\.json)?$' | awk '{print $4}')";

if [ -n "${remote_vars}" ]; then
  mkdir -p 'build';
  echo 'Found the following remote tfvars files:';
  for vars_file in ${remote_vars}; do
    echo "- ${vars_file}";
    remote_vars_local_file_path="build/${vars_file}";
    remote_vars_file_path="${remote_vars_path}${vars_file}";
    aws s3 cp "${remote_vars_file_path}" "${remote_vars_local_file_path}" \
      || error_and_die "S3 tfvars file is present, but inaccessible. Ensure you have permission to read ${remote_vars_file_path}";
  done;
fi;

# Use versions TFVAR files if exists
readonly versions_file_name="versions_${region}_${environment}.tfvars";
readonly versions_file_path="${base_path}/etc/${versions_file_name}";

# Check for presence of an environment variables file, and use it if readable
if [ -n "${environment}" ]; then
  readonly env_file_path="${base_path}/etc/env_${region}_${environment}.tfvars";
fi;

# Check for presence of a global variables file, and use it if readable
readonly global_vars_file_name="global.tfvars";
readonly global_vars_file_path="${base_path}/etc/${global_vars_file_name}";

# Check for presence of a region variables file, and use it if readable
readonly region_vars_file_name="${region}.tfvars";
readonly region_vars_file_path="${base_path}/etc/${region_vars_file_name}";

# Parse comma-delimited group into an array
declare -a groups=();
if [ -n "${group}" ]; then
  IFS=',' read -ra groups <<< "${group}";
fi;

# Collect the paths of the variables files to use
declare -a tf_var_file_paths;

# Use Global and Region first, to allow potential for terraform to do the
# honourable thing and override global and region settings with environment
# specific ones; however we do not officially support the same variable
# being declared in multiple locations, and we warn when we find any duplicates
[ -f "${global_vars_file_path}" ] && tf_var_file_paths+=("${global_vars_file_path}");
[ -f "${region_vars_file_path}" ] && tf_var_file_paths+=("${region_vars_file_path}");

# If group(s) have been specified, load the vars for each group. If we are to assume
# terraform correctly handles override-ordering (which to be fair we don't hence
# the warning about duplicate variables below) we add this to the list after
# global and region-global variables, but before the environment variables
# so that the environment can explicitly override variables defined in the group(s).
for group_name in "${groups[@]}"; do
  declare group_vars_file_name="group_${group_name}.tfvars";
  declare group_vars_file_path="${base_path}/etc/${group_vars_file_name}";
  if [ -f "${group_vars_file_path}" ]; then
    tf_var_file_paths+=("${group_vars_file_path}");
  else
    echo -e "[WARNING] Group \"${group_name}\" has been specified, but no group variables file is available at ${group_vars_file_path}";
  fi;
done;

# Environment is normally expected, but in bootstrapping it may not be provided
if [ -n "${environment}" ]; then
  if [ -f "${env_file_path}" ]; then
    tf_var_file_paths+=("${env_file_path}");
  else
    echo -e "[WARNING] Environment \"${environment}\" has been specified, but no environment variables file is available at ${env_file_path}";
  fi;
fi;

# If present and readable, use versions too
[ -f "${versions_file_path}" ] && tf_var_file_paths+=("${versions_file_path}");

# Pull down any tfvars files from S3 to use with Terraform
# This replaces the single dynamic.tfvars file with support for multiple remote tfvars files
if [ -n "${remote_vars}" ]; then
  for vars_file in ${remote_vars}; do
    remote_vars_local_file_path="build/${vars_file}";
    tf_var_file_paths+=("${remote_vars_local_file_path}");
  done;
fi;

# Warn on duplication
duplicate_variables="$(cat "${tf_var_file_paths[@]}" | sed -n -e 's/\(^[a-zA-Z0-9_\-]\+\)\s*=.*$/\1/p' | sort | uniq -d)";
[ -n "${duplicate_variables}" ] \
  && echo -e "
###################################################################
# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING #
###################################################################
The following input variables appear to be duplicated:

${duplicate_variables}

Ensure this is intentional behaviour, and that the order of
precedence for variable values is as you expect.
###################################################################";

# Build up the tfvars arguments for terraform command line
for file_path in "${tf_var_file_paths[@]}"; do
  tf_var_params+=" -var-file=${file_path}";
done;

# Ensure the region from -r/--region always takes precedence over any
# region value defined in tfvars files. -var has higher precedence than
# -var-file in terraform, so this guarantees the -r flag is authoritative.
# See: https://github.com/tfutils/tfscaffold/issues/37
tf_var_params+=" -var region=${region}";

# Warn if any tfvars file defines a region that differs from the -r value.
# The -var override above means the -r value will win, but the user should
# know their tfvars are being overridden to avoid unintended consequences.
for file_path in "${tf_var_file_paths[@]}"; do
  if [ -f "${file_path}" ]; then
    declare tfvars_region="$(sed -n -e 's/^\s*region\s*=\s*"\{0,1\}\([^"]*\)"\{0,1\}\s*$/\1/p' "${file_path}")";
    if [ -n "${tfvars_region}" ] && [ "${tfvars_region}" != "${region}" ]; then
      echo -e "
###################################################################
# WARNING: Region mismatch detected                               #
###################################################################
# The file: ${file_path}
# defines region = \"${tfvars_region}\"
# but tfscaffold is running with region = \"${region}\"
#
# The -r/--region value (${region}) will take precedence.
# If this is not intentional, update the tfvars file or change
# the -r flag to match.
###################################################################";
    fi;
    unset tfvars_region;
  fi;
done;

##
# Start Doing Real Things
##

# Really Hashicorp? Really?!
#
# In order to work with terraform >=0.9.2 (I say 0.9.2 because 0.9 prior
# to 0.9.2 is barely usable due to key bugs and missing features)
# we now need to do some ugly things to our terraform remote backend configuration.
# The long term hope is that they will fix this, and maybe remove the need for it
# altogether by supporting interpolation in the backend config stanza.
#
# For now we're left with this garbage, and no more support for <0.9.0.
if [ -f backend_tfscaffold.tf ]; then
  echo -e 'WARNING: backend_tfscaffold.tf exists and will be overwritten!' >&2;
fi;

declare backend_prefix='';
declare backend_filename='';

if [ "${bootstrap}" == 'true' ]; then
  backend_prefix="${project}/${aws_account_id}/${region}/bootstrap";
  backend_filename="bootstrap.tfstate";
else
  backend_prefix="${project}/${aws_account_id}/${region}/${environment}";
  backend_filename="${component_name}.tfstate";
fi;

readonly backend_key="${backend_prefix}/${backend_filename}";

# If AWS_PROFILE is set, inject it into the backend config so that
# SSO-based local deploys do not silently fall back to the default profile.
declare backend_profile="${AWS_PROFILE:-}";
declare backend_profile_config='';
if [ -n "${backend_profile}" ]; then
  backend_profile_config="
    profile        = \"${backend_profile}\"";
fi;

declare backend_config='';
if [ "${lock_table}" == 'true' ]; then
  backend_config="terraform {
  backend \"s3\" {
    region         = \"${region}\"
    bucket         = \"${bucket}\"
    key            = \"${backend_key}\"
    encrypt        = true
    dynamodb_table = \"${bucket}\"${backend_profile_config}
  }
}";
else
  backend_config="terraform {
  backend \"s3\" {
    region  = \"${region}\"
    bucket  = \"${bucket}\"
    key     = \"${backend_key}\"
    encrypt = true${backend_profile_config}
  }
}";
fi;

# We're now all ready to go. All that's left is to:
#   * Write the backend config
#   * terraform init
#   * terraform ${action}
#
# But if we're dealing with the special bootstrap component
# we can't remotely store the backend until we've bootstrapped it
#
# So IF the S3 bucket already exists, we will continue as normal
# because we want to be able to manage changes to an existing
# bootstrap bucket. But if it *doesn't* exist, then we need to be
# able to plan and apply it with a local state, and *then* configure
# the remote state.

# In default operations we assume we are already bootstrapped
declare bootstrapped='true';

# If we are in bootstrap mode, we need to know if we have already bootstrapped
# or we are working with or modifying an existing bootstrap bucket
if [ "${bootstrap}" == 'true' ]; then
  # For this exist check we could do many things, but we explicitly perform
  # an ls against the key we will be working with so as to not require
  # permissions to, for example, list all buckets, or the bucket root keyspace
  aws s3 ls "s3://${bucket}/${backend_prefix}/${backend_filename}" >/dev/null 2>&1;
  [ "$?" -eq 0 ] || bootstrapped='false';
fi;

if [ "${bootstrapped}" == 'true' ]; then
  echo -e "${backend_config}" > backend_tfscaffold.tf \
    || error_and_die "Failed to write backend config to $(pwd)/backend_tfscaffold.tf";

  # Nix the horrible hack on exit
  trap "rm -f '$(pwd)/backend_tfscaffold.tf'" EXIT;

  declare lockfile_or_upgrade='';
  [ -n "${lockfile}" ] && lockfile_or_upgrade="${lockfile}" || lockfile_or_upgrade='-upgrade';

  # Configure remote state storage
  echo "Setting up S3 remote state from s3://${bucket}/${backend_key}";
  [ "${lock_table}" == 'true' ] && echo "Using DynamoDB Table for state locking: ${bucket}";
  ${terraform_bin} init ${no_color} ${lockfile_or_upgrade} \
    || error_and_die 'Terraform init failed';

  if [ "${action}" == 'destroy' ] && [ "${destroy_response}" == 'I am not an idiot, I know what I am doing!' ]; then
    echo -e "terraform {\n  backend \"local\" {}\n}" > backend_tfscaffold.tf;
    ${terraform_bin} init -migrate-state -force-copy;
  fi;
else
  # We are bootstrapping. Download the providers, skip the backend config.
  ${terraform_bin} init \
    -backend=false \
    ${no_color} \
    ${lockfile} \
    || error_and_die 'Terraform init failed';
fi;

case "${action}" in
  'plan')
    if [ -n "${build_id}" ]; then
      mkdir -p build;

      plan_file_name="${component_name}_${build_id}.tfplan";
      plan_file_remote_key="${backend_prefix}/plans/${plan_file_name}";

      out="-out=build/${plan_file_name}";
    fi;

    if [ "${detailed_exitcode}" == 'true' ]; then
      detailed='-detailed-exitcode';
    fi;

    ${terraform_bin} "${action}" \
      -input=false \
      ${refresh} \
      ${tf_var_params} \
      ${extra_args} \
      ${destroy} \
      ${out} \
      ${detailed} \
      -parallelism=300;

    status="${?}";

    # Even when detailed exitcode is set, a 1 is still a fail,
    # so exit
    # (detailed exit codes are 0 and 2)
    if [ "${status}" -eq 1 ]; then
      error_and_die 'Terraform plan failed';
    fi;

    if [ -n "${build_id}" ]; then
      aws s3 cp "build/${plan_file_name}" "s3://${bucket}/${plan_file_remote_key}" \
        || error_and_die "Plan file upload to S3 failed (s3://${bucket}/${plan_file_remote_key})";
    fi;

    exit "${status}";
    ;;
  'graph')
    mkdir -p build || error_and_die "Failed to create output directory '$(pwd)/build'";
    ${terraform_bin} graph ${extra_args} -draw-cycles | dot -Tpng > "build/${project}-${aws_account_id}-${region}-${environment}.png" \
      || error_and_die 'Terraform simple graph generation failed';
    ${terraform_bin} graph ${extra_args} -draw-cycles -verbose | dot -Tpng > "build/${project}-${aws_account_id}-${region}-${environment}-verbose.png" \
      || error_and_die 'Terraform verbose graph generation failed';
    exit 0;
    ;;
  'apply'|'destroy'|'refresh')
    # User can specify -w/--compact-warnings for all their commands,
    # and we'll safely ignore it for commands that don't support it
    extra_args+=" ${compact_warnings}";

    # We're going to write a new one of these, and we don't want the user
    # thinking the stale file is up to date if we don't update it successfully
    [ "${output_json}" == 'true' ] && [ -f '.terraform.output.json' ] && echo "Deleting old outputs file: $(pwd)/.terraform.output.json" && rm -f .terraform.output.json;

    # Support for terraform <0.10 is now deprecated
    if [ "${action}" == 'apply' ]; then
      extra_args+=' -auto-approve=true';
    else # action is `destroy`
      # Check terraform version - if pre-0.15, need to add `-force`; 0.15 and above instead use `-auto-approve`
      if [ "$(${terraform_bin} version | head -n1 | cut -d' ' -f2 | cut -d'.' -f1)" == 'v0' ] && [ "$(${terraform_bin} version | head -n1 | cut -d' ' -f2 | cut -d'.' -f2)" -lt 15 ]; then
        echo 'Compatibility: Adding to terraform arguments: -force';
        force='-force';
      else
        extra_args+=' -auto-approve';
      fi;
    fi;

    if [ -n "${build_id}" ]; then
      mkdir -p build;
      plan_file_name="${component_name}_${build_id}.tfplan";
      plan_file_remote_key="${backend_prefix}/plans/${plan_file_name}";

      aws s3 cp "s3://${bucket}/${plan_file_remote_key}" "build/${plan_file_name}" \
        || error_and_die "Plan file download from S3 failed (s3://${bucket}/${plan_file_remote_key})";

      apply_plan="build/${plan_file_name}";

      ${terraform_bin} "${action}" \
        -input=false \
        ${refresh} \
        -parallelism=300 \
        ${extra_args} \
        ${force} \
        ${apply_plan};
      exit_code=$?;
    else
      ${terraform_bin} "${action}" \
        -input=false \
        ${refresh} \
        ${tf_var_params} \
        -parallelism=300 \
        ${extra_args} \
        ${force};
      exit_code=$?;

      if [ "${bootstrapped}" == 'false' ]; then
        # If we are here, and we are in bootstrap mode, and not already bootstrapped,
        # Then we have just bootstrapped for the first time! Congratulations.
        # Now we need to copy our state file into the bootstrap bucket
         echo -e "${backend_config}" > backend_tfscaffold.tf \
          || error_and_die "Failed to write backend config to $(pwd)/backend_tfscaffold.tf";

        # Nix the horrible hack on exit
        trap "rm -f '$(pwd)/backend_tfscaffold.tf'" EXIT;

        # Push Terraform Remote State to S3
        # TODO: Add -upgrade to init when we drop support for <0.10
        echo 'yes' | ${terraform_bin} init ${lockfile} || error_and_die 'Terraform init failed';

        # Hard cleanup
        rm -f terraform.tfstate; # Prime not the backup

        # This doesn't mean anything here, we're just celebrating!
        bootstrapped='true';
      fi;

    fi;

    if [ "${exit_code}" -ne 0 ]; then
      error_and_die "Terraform ${action} failed with exit code ${exit_code}";
    fi;

    if [ "${output_json}" == 'true' ] && [ "${action}" != 'destroy' ]; then
      echo "Writing terraform output to $(pwd)/.terraform.output.json";
      ${terraform_bin} output -json -no-color > .terraform.output.json;
    fi;

    if [ -f 'post.sh' ]; then
      source post.sh "${region}" "${environment}" "${action}" \
        || error_and_die "Component post script execution failed with exit code ${?}";
    fi;
    ;;
  'output')
    # Dedicated output action: run terraform output with optional JSON file generation.
    # Cleans up stale output file first to avoid confusion.
    if [ "${output_json}" == 'true' ] && [ -f '.terraform.output.json' ]; then
      echo "Deleting old outputs file: $(pwd)/.terraform.output.json";
      rm -f .terraform.output.json;
    fi;

    ${terraform_bin} "${action}" ${extra_args};
    status="${?}";

    if [ "${status}" -ne 0 ]; then
      exit "${status}";
    fi;

    if [ "${output_json}" == 'true' ]; then
      echo "Writing terraform output to $(pwd)/.terraform.output.json";
      ${terraform_bin} output -json -no-color > .terraform.output.json \
        || error_and_die 'Terraform output -json failed.';
    fi;
    ;;
  '*taint')
    ${terraform_bin} "${action}" ${extra_args} || error_and_die "Terraform ${action} failed.";
    ;;
  'import')
    ${terraform_bin} "${action}" ${tf_var_params} ${extra_args} || error_and_die "Terraform ${action} failed.";
    ;;
  'shell')
    echo -e "Here's a shell for the ${component} component.\nIf you want to run terraform actions specific to the ${environment} environment, pass the following options to your terraform commands:\n\n${tf_var_params} ${extra_args}\n\n'exit 0' / 'Ctrl-D' to continue, other exit codes will abort tfscaffold with the same code.";
    bash -l || exit "${?}";
    ;;
  *)
    echo -e 'Generic action case invoked. Only the additional arguments will be passed to terraform, you break it you fix it:';
    echo -e "\t${terraform_bin} ${action} ${extra_args}";
    ${terraform_bin} "${action}" ${extra_args} \
      || error_and_die "Terraform ${action} failed.";
    ;;
esac;

popd;

if [ -f 'post.sh' ]; then
  source post.sh "${region}" "${environment}" "${action}" \
    || error_and_die "Global post script execution failed with exit code ${?}";
fi;

exit 0;

# vim:set et ts=2 sw=2:
