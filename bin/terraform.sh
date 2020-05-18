#!/bin/bash
# Terraform Scaffold from @TFUtils, tweaked by @SeboLabs

readonly script_ver="1.2.0";

############
# FUNCTIONS
####################################################################################################
color_err="\e[1m\e[31m";
color_ok="\e[1m\e[32m";
color_wrn="\e[1m\e[33m";
color_end="\e[0m";

function check_shell_colors {
  if [[ ${TF_CLI_ARGS} =~ "-no-color" ]]; then
    unset color_start;
    unset color_end;
    export BASHLOG_COLOURS=0;
  fi
}

function error_and_die {
  color_start=$color_err;
  check_shell_colors;

  echo -e "\n${color_start}[ERROR]${color_end} ${1}" >&2;
  exit 1;
};

function log {
  case $1 in
    info)
      level="INFO";
      color_start=$color_ok;
      ;;
    warn)
      level="WARNING";
      color_start=$color_wrn;
      ;;
    *)
      ;;
  esac;
  message=$2;
  check_shell_colors;

  echo -e "\n${color_start}[${level}]${color_end} ${message}";
}

function version {
  echo "${script_ver}";
}

function usage {
  cat <<EOF
Usage: ${0} \\
  -a/--action        [action] \\
  -b/--bucket-prefix [bucket_prefix] \\
  -c/--component     [component_name] \\
  -e/--environment   [environment] \\
  -g/--group         [group]
  -p/--project       [project] \\
  -o/--output-plan   [output_plan] \\
  -r/--region        [region] \\
  -- \\
  <additional arguments to forward to the terraform binary call>

action:
  - Special actions:
    * plan / plan-destroy
    * apply / destroy
    * graph
    * taint / untaint
  - Generic actions:
    * See https://www.terraform.io/docs/commands/

bucket_prefix (optional):
  Defaults to: "\${project_name}-terraformscaffold"
  - myproject-terraform
  - terraform-yourproject
  - my-first-terraformscaffold-project

component_name:
  - the name of the terraform component module in the components directory

environment:
  - dev
  - test
  - prod
  - management

group:
  - dev
  - live
  - mytestgroup

project:
  - The name of the project being deployed

region (optional):
  Defaults to value of \$AWS_DEFAULT_REGION
  - the AWS region name unique to all components and terraform processes

additional arguments:
  Any arguments provided after "--" will be passed directly to terraform as its own arguments
EOF
};

##########################
# LOCAL CONFIG VALIDATION
####################################################################################################

getopt_out=$(getopt -T);
if (( $? != 4 )) && [[ -n $getopt_out ]]; then
  error_and_die "Non GNU getopt detected. If you're using a Mac then try \"brew install gnu-getopt\"";
fi;

#######
# PREP
####################################################################################################

readonly raw_arguments="${*}";
ARGS=$(getopt \
  -o hva:b:c:e:g:i:p:r:o: \
  -l "help,version,bootstrap,action:,bucket-prefix:,component:,environment:,group:,project:,region:,output-plan:" \
  -n "${0}" \
  -- \
  "$@" \
);

if [ $? -ne 0 ]; then
  usage;
  error_and_die "Command line argument parse failure";
fi;

eval set -- "${ARGS}";

declare bootstrap="false";
declare component_arg;
declare region_arg;
declare environment_arg;
declare group;
declare action;
declare bucket_prefix;
declare project;

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
    -g|--group)
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
    -p|--project)
      shift;
      if [ -n "${1}" ]; then
        project="${1}";
        shift;
      fi;
      ;;
    -o|--output-plan)
      shift;
      declare output_plan;
      if [ -n "${1}" ]; then
        output_plan="${1}";
        shift;
      fi;
      ;;
    --bootstrap)
      shift;
      bootstrap="true"
      ;;
    --)
      shift;
      break;
      ;;
  esac;
done;

declare extra_args="${@}"; # All arguments supplied after "--"

# Determine where I am and from that derive basepath and project name
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
base_path="${script_path%%\/bin}";
project_name_default="${base_path##*\/}";
status=0;

echo "Args ${raw_arguments}";

# Set variables
readonly region="${region_arg:-${AWS_DEFAULT_REGION}}";
[ -n "${region}" ] \
  || error_and_die "No AWS region specified. No -r/--region argument supplied and AWS_DEFAULT_REGION undefined";

[ -n "${project}" ] \
  || error_and_die "Required argument missing: -p/--project";

if [ "${bootstrap}" == "true" ]; then
  [ -n "${component_arg}" ] \
    && error_and_die "The --bootstrap parameter and the -c/--component parameter are mutually exclusive";
  [ -n "${environment_arg}" ] \
    && error_and_die "The --bootstrap parameter and the -e/--environment parameter are mutually exclusive";
else
  [ -n "${component_arg}" ] \
    || error_and_die "Required argument missing: -c/--component";
  readonly component="${component_arg}";

  [ -n "${environment_arg}" ] \
    || error_and_die "Required argument missing: -e/--environment";
  readonly environment="${environment_arg}";
fi;

[ -n "${action}" ] \
  || error_and_die "Required argument missing: -a/--action";

# Query canonical AWS Account ID
aws_account_id="$(aws sts get-caller-identity --query 'Account' --output text)";
if [ -n "${aws_account_id}" ]; then
  log "info" "AWS Account ID: ${aws_account_id}";
else
  error_and_die "Couldn't determine AWS Account ID. \"aws sts get-caller-identity --query 'Account' --output text\" provided no output";
fi;

# Validate AWS Credentials available
iam_identity="$(aws sts get-caller-identity --query 'Arn' --output text)";
if [ -n "${iam_identity}" ]; then
  log "info" "AWS Credentials Found. Using ARN: '${iam_identity}'";
else
  error_and_die "No AWS Credentials Found. \"aws sts get-caller-identity --query 'Arn' --output text\" responded with ARN '${iam_identity}'";
fi;

# Validate S3 bucket - set default if undefined
if [ -n "${bucket_prefix}" ]; then
  readonly bucket="${bucket_prefix}-${aws_account_id}-${region}"
  log "info" "Using S3 bucket s3://${bucket}";
else
  readonly bucket="${project}-terraformscaffold-${aws_account_id}-${region}";
  log "info" "No bucket prefix specified. Using S3 bucket s3://${bucket}";
fi;

declare component_path;
if [ "${bootstrap}" == "true" ]; then
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

# Calculate action properties
case "${action}" in
  apply)
    refresh="-refresh=true";
    out_plan="${output_plan}"
    ;;
  destroy)
    destroy='-destroy';
    force='-force';
    refresh="-refresh=true";
    ;;
  plan)
    refresh="-refresh=true";
    out_plan="-out=${output_plan}"
    ;;
  plan-destroy)
    action="plan";
    destroy="-destroy";
    refresh="-refresh=true";
    ;;
  *)
    ;;
esac;

# Tell terraform to moderate its output to be a little more friendly to automation wrappers
export TF_IN_AUTOMATION="true";

# Configure the plugin-cache location so plugins are not downloaded to individual components
declare default_plugin_cache_dir="$(pwd)/plugin-cache";
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${default_plugin_cache_dir}}"
mkdir -p "${TF_PLUGIN_CACHE_DIR}" \
  || error_and_die "Failed to created the plugin-cache directory (${TF_PLUGIN_CACHE_DIR})";
[ -w ${TF_PLUGIN_CACHE_DIR} ] \
  || error_and_die "plugin-cache directory (${TF_PLUGIN_CACHE_DIR}) not writable";

# Clear cache, safe enough as we enforce plugin cache
rm -rf ${component_path}/.terraform;

# Make sure we're running in the component directory
pushd "${component_path}";
readonly component_name=$(basename ${component_path});

# Check for presence of tfenv and a .terraform-version file and use them
tfenv_bin="$(which tfenv 2>/dev/null)";
if [[ -n "${tfenv_bin}" && -x "${tfenv_bin}" && -f .terraform-version ]]; then
  ${tfenv_bin} install;
fi;

declare tf_var_params;

if [ "${bootstrap}" == "true" ]; then
  if [ "${action}" == "destroy" ]; then
    error_and_die "You cannot destroy a bootstrap bucket using terraformscaffold, it's just too dangerous. If you're absolutely certain that you want to delete the bucket and all contents, including any possible state files environments and components within this project, then you will need to do it from the AWS Console. Note you cannot do this from the CLI because the bootstrap bucket is versioned, and even the --force CLI parameter will not empty the bucket of versions";
  fi;

  # Bootstrap requires explicitly and only these parameters
  tf_var_params+=" -var aws_region=${region}";
  tf_var_params+=" -var project=${project}";
  tf_var_params+=" -var bucket_name=${bucket}";
  tf_var_params+=" -var aws_account_id=${aws_account_id}";
else
  # Use versions TFVARS files if exists
  readonly versions_file_name="versions_${region}_${environment}.tfvars";
  readonly versions_file_path="${base_path}/etc/${versions_file_name}";

  # Check environment name is a known environment
  readonly env_file_path="${base_path}/etc/env_${region}_${environment}.tfvars";
  if [ ! -f "${env_file_path}" ]; then
    error_and_die "Unknown environment - ${env_file_path} does not exist!";
  fi;

  # Check for presence of a global variables file, and use it if readable
  readonly global_vars_file_name="global.tfvars";
  readonly global_vars_file_path="${base_path}/etc/${global_vars_file_name}";

  # Check for presence of a region variables file, and use it if readable
  readonly region_vars_file_name="${region}.tfvars";
  readonly region_vars_file_path="${base_path}/etc/${region_vars_file_name}";

  # Check for presence of a group variables file if specified, and use it if readable
  if [ -n "${group}" ]; then
    readonly group_vars_file_name="group_${group}.tfvars";
    readonly group_vars_file_path="${base_path}/etc/${group_vars_file_name}";
  fi;

  # Collect the paths of the variables files to use
  declare -a tf_var_file_paths;

  # Use Global and Region first
  [ -f "${global_vars_file_path}" ] && tf_var_file_paths+=("${global_vars_file_path}");
  [ -f "${region_vars_file_path}" ] && tf_var_file_paths+=("${region_vars_file_path}");

  # If a group has been specified, load the vars for the group.
  if [ -n "${group}" ]; then
    if [ -f "${group_vars_file_path}" ]; then
      tf_var_file_paths+=("${group_vars_file_path}");
    else
      log "warn" "Group \"${group}\" has been specified, but no group variables file is available at ${group_vars_file_path}";
    fi;
  fi;

  tf_var_file_paths+=("${env_file_path}");

  # If present and readable, use versions variables too
  [ -f "${versions_file_path}" ] && tf_var_file_paths+=("${versions_file_path}");

  # Warn on variables duplication
  duplicate_variables="$(cat "${tf_var_file_paths[@]}" | sed -n -e 's/\(^[a-zA-Z0-9_\-]\+\)\s*=.*$/\1/p' | sort | uniq -d)";
  [ -n "${duplicate_variables}" ] \
    && log "warn" "Duplicated variables found:\n${duplicate_variables}";

  # Build up the tfvars arguments for terraform command line
  if [[ "${action}" != "apply" ]] || ([[ "${action}" == "apply" && -z "$output_plan" ]]); then
    for file_path in "${tf_var_file_paths[@]}"; do
      tf_var_params+=" -var-file=${file_path}";
    done;
  fi;
fi;

############################
# CONFIGURE BACKEND AND RUN
####################################################################################################
if [ -f backend_terraformscaffold.tf ]; then
  log "warn" "The 'backend_terraformscaffold.tf' file exists and will be overwritten!\nPlease make sure you're not checking it in to source control.";
fi;

declare backend_prefix;
declare backend_filename;

if [ "${bootstrap}" == "true" ]; then
  backend_prefix="${project}/${aws_account_id}/${region}/bootstrap";
  backend_filename="bootstrap.tfstate";
  dynamodb_table="null";
else
  backend_prefix="${project}/${aws_account_id}/${region}/${environment}";
  backend_filename="${component_name}.tfstate";
  dynamodb_table="\"${bucket}\"";
fi;

readonly backend_key="${backend_prefix}/${backend_filename}";
readonly backend_config="terraform {
  backend \"s3\" {
    region         = \"${region}\"
    bucket         = \"${bucket}\"
    key            = \"${backend_key}\"
    dynamodb_table = "${dynamodb_table}"
  }
}";

# Next steps:
#   * Save backend config
#   * Run terraform init -upgrade
#   * Rub terraform ${action}
# But if we're dealing with the special bootstrap component we can't remotely store the backend until we've bootstrapped it.
# If the S3 bucket already exists, we will continue as normal because we want to be able to manage changes to an existing bootstrap bucket.
# But if it *doesn't* exist, then we need to be able to plan and apply it with a local state, and *then* configure the remote state.

# In default operations we assume we are already bootstrapped
declare bootstrapped="true";

# If we are in bootstrap mode, we need to know if we have already bootstrapped
# or we are working with or modifying an existing bootstrap bucket
if [ "${bootstrap}" == "true" ]; then
  aws s3 ls s3://${bucket}/${backend_prefix}/${backend_filename} >/dev/null 2>&1;
  [ $? -eq 0 ] || bootstrapped="false";
fi;

if [ "${bootstrapped}" == "true" ]; then
  echo -e "${backend_config}" > backend_terraformscaffold.tf \
    || error_and_die "Failed to write backend config to $(pwd)/backend_terraformscaffold.tf";

  # Nix the horrible hack on exit
  trap "rm -f $(pwd)/backend_terraformscaffold.tf" EXIT;

  # Configure remote state storage
  log "info" "Setting up S3 remote state from s3://${bucket}/${backend_key}\n";
  terraform init -upgrade \
    || error_and_die "Terraform init failed";
else
  # We are bootstrapping. Download the providers, skip the backend config
  terraform init -backend=false \
    || error_and_die "Terraform init failed";
fi;

case "${action}" in
  'plan')
    terraform "${action}" \
      -input=false \
      ${refresh} \
      ${tf_var_params} \
      ${extra_args} \
      ${destroy} \
      ${out_plan} \
      || error_and_die "Terraform plan failed";

    exit ${status};
    ;;
  'graph')
    mkdir -p build || error_and_die "Failed to create output directory '$(pwd)/build'";
    terraform graph -draw-cycles | dot -Tpng > build/${project}-${aws_account_id}-${region}-${environment}.png \
      || error_and_die "Terraform simple graph generation failed";
    terraform graph -draw-cycles -verbose | dot -Tpng > build/${project}-${aws_account_id}-${region}-${environment}-verbose.png \
      || error_and_die "Terraform verbose graph generation failed";
    exit 0;
    ;;
  'apply'|'destroy')
    extra_args+=" -auto-approve=true";

    terraform "${action}" \
      -input=false \
      ${refresh} \
      ${tf_var_params} \
      -parallelism=10 \
      ${extra_args} \
      ${force} \
      ${out_plan};
    exit_code=$?;

    if [ "${bootstrapped}" == "false" ]; then
      # After bootstrapping, we need to copy our state file into the bootstrap bucket
      echo -e "${backend_config}" > backend_terraformscaffold.tf \
        || error_and_die "Failed to write backend config to $(pwd)/backend_terraformscaffold.tf";

      # Nix the horrible hack on exit
      trap "rm -f $(pwd)/backend_terraformscaffold.tf" EXIT;

      # Push Terraform Remote State to S3
      echo "yes" | terraform init -upgrade || error_and_die "Terraform init failed";

      # Hard cleanup
      rm -f backend_terraformscaffold.tf;
      rm -f terraform.tfstate # Prime not the backup
      rm -rf .terraform;
    fi;

    if [ ${exit_code} -ne 0 ]; then
      error_and_die "Terraform ${action} failed with exit code ${exit_code}";
    fi;
    ;;
  '*taint')
    terraform "${action}" ${extra_args} || error_and_die "Terraform ${action} failed.";
    ;;
  'import')
    terraform "${action}" ${tf_var_params} ${extra_args} || error_and_die "Terraform ${action} failed.";
    ;;
  *)
    log "warn" "Generic action case invoked. Only the additional arguments will be passed to terraform, you break it you fix it:";
    echo -e "\tterraform ${action} ${extra_args}";
    terraform "${action}" ${extra_args} \
      || error_and_die "Terraform ${action} failed.";
    ;;
esac;

popd;
exit 0;
