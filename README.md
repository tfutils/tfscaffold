# terraformscaffold

A framework for controlling multi-environment multi-component terraform-managed AWS infrastructure

## Overview

Terraform scaffold consists of a terraform wrapper bash script, a bootstrap script and a set of directories providing the locations to store terraform code and variables.

| Thing	| Things about the Thing |
|-------|------------------------|
| bin/terraform.sh | The master terraform wrapper script |
| bootstrap/bootstrap.sh | The S3 bucket bootstrapping script |
| components/ |	The location for terraform "components". Terraform code intended to be run directly as a root module. |
| etc/ | The location for environment-specific terraform variables files:<br/>`env_{region}_{environment}.tfvars`<br/>`versions_{region}_{environment}.tfvars` |
| modules/ | The optional location for terraform modules called by components |

## Concepts & Assumptions

### Multi-Component Environment Concept

The Scaffold is built around the concept that a logical "environment" may consist of any number of independent components across independent AWS accounts. What provides consistency across these components, and therefore defines the environment, are the variables shared between the components. For example, the CIDR block defining a primary VPC for a production environment is needed by the component that creates the VPC, it may also be needed by components in other VPCs or accounts. All components in a production enviroment are likely to share the "envirornment" variable value "production".

Scaffold achieves this by maintaining variables specific to an environment in the file _etc/env_{region}_{environment}.tfvars_, and then providing those variables as inputs to all components run for that environment. Any variables not required by a component are safely ignored, but all components have visibility of all variables for an environment.

Important Note: Variables in the Env and Versions variables files are not merged. You cannot, for example, define the same map variable in both files and have the keys in each definition merged into a resulting set. When a variable is defined more than once, the last one terraform evaluates takes precedence and overrides any previously encountered definition. To prevent unexpected consequences, never define variable values in more than one place.

### State File Location Consistency and Referencing

Scaffold uses AWS S3 for storage of tfstate files. The bucket and location are specifically defined to be predictable to organise their storage and permit the use of terraform_remote_state resources. Any scaffold component can reliably refer to the S3 location of the state file for another component and depend upon the outputs provided. The naming convention is:     _s3://${project}-terraformscaffold-${aws_account_id}-${aws_region}/${project}/${aws_account_id}/${aws_region}/${environment}/${component}.tfstate_. Each functional scaffold S3 bucket will only therefore contain content within the keyspace _/${project}/${aws_account_id}/${aws_region}_ as these are unique to the bucket as well as all contents. The reason for the use of this keyspace is to permit the aggregation of state files from multiple bucket into a master bucket for backup or read-only review purposes. All scaffold buckets relevant to a person or organisation could be safely synchronised to a single bucket without fear of keyspace overlap.

### Variables Files: Environment & Versions

Scaffold provides a logical separation of two types of environment variable. Standard static variables and frequently-changing versions variables. This seperation is purely logical, not functional. It makes no functional difference in which file a variable lives, or even whether a versions variables file exists; but it provides the capacity to seperate out mostly static variables that define the construction of the environment from variables that could change on each apply providing new AMI IDs, or dockerised application versions or database snapshot IDs when recreating development and testing databases.

### AWS Credentials

Terraform Scaffold does not provide any mechanism for running terraform across multiple AWS accounts simultaneously, storing state files in a different account to the account being modified or any other functionality that would require Scaffold to intelligently manage AWS credentials. After extensive research and development it has become apparant that, despite some features available in terraform to handle more than one AWS account and the use of IAM roles, the features are not sufficiently mature or flexible to allow their application in a generic form.

Therefore, to ensure widest possible reach and capability of Scaffold, it requires that a specific set of AWS credentials be provided to it at invocation. These credentials must have the necessary access to read and write to the bootstrapped S3 state file bucket, and to create/modify/destroy the AWS resources being controlled via terraform.

Credentials can be provided in any of the standard mechanisms provided by the Boto search path, for example, EC2 Instance Profiles, an _~/.aws/credentials_ file or _AWS_ACCESS_KEY_ID_ and _AWS_SECRET_ACCESS_KEY_ environment variables.

If you want to make use of instance profiles, MFA tokens, AWS STS, Cross Account Roles or other fantastic IAM trickery, the recommended practice is to use a static access key or instance profile to call AWS STS using the AWS CLI tools, and then assign the temporary credentials that are generated to the AWS credential environment variables so that terraform can make use of them. This is done externally to Scaffold and would normally be integrated into a Jenkins job as a step to perform to prepare the environment before calling Scaffold.

### pre_apply.sh & post_apply.sh

Although as yet somewhat unrefined, Scaffold provides the capacity to incorporate additional scripted actions to take prior to and after running terraform on a given component. If there is a file called "pre_apply.sh" present in the top level of the component you are working with, then it will be executed as a bash script prior to any terraform action. If a file called post_apply.sh is present it will be executed immediately following any terraform action. This capability clearly could do with some improvement to support complex deployments with script dependencies, but as yet I have none to play with.

### Encrypted Variables / Secrets

This is an experimental feature that is not necessarily an appropriate solution for secrets management in production systems due to the way state files are stored with all terraform variables included. In general a resource that requires secret information should look up that information itself once it has been created using role based credentials. If however you are simply looking for a solution to move secrets out of your Git repository and into S3 which can be locked down, then this might be useful.

On invocation, Scaffold checks for a file at _s3://${bucket}/${project}/secrets/secret_${region}_${environment}.tfvars.enc_. If it finds one, it attempts to use KMS to decrypt the contents into an array and then process each line as a key=value set of variables. Each one is then provided to terraform as an input variable in the form: -var 'key=value'. This ensures that the secret is never stored unencrypted on disk even temporarily during terraform apply. However.. the completely unencrypted format of the terraform tfplan and tfstate files means these secrets will still make it to disk and be stored in the clear, hence the above caveats. This is not a complete secrets management solution, but it is a useful quick fix to get your secrets out of Git while you work on a better long term plan.

## Usage
### Bootstrapping
Before using Scaffold, a bootstrapping stage is required. Scaffold is responsible for creating and maintaining the S3 buckets it uses to store component state files and even keeps the state file that defines the scaffold bucket in the same bucket. This is done with a script specifically designed to run a basic apply of the bootstrap code to create the bucket, and then configures the created bucket as a remote state location for itself. Once the bucket has been created, it can then be used for any terraform apply for the specific combination of project, region and AWS account.

It is not recommended to modify the bootstrap code after creation as direct application of modified bootstrap code risks the integrity of the state files stored in the bucket; however this can be mitigated by configuring synchronisation with a master backup bucket external to Scaffold management.

The bootstrap script lives at bootstrap/bootstrap.sh and its usage as of 25/01/2017 is:

```bash
bootstrap/bootstrap.sh \
    -p/--project `project` \
    -b/--bucket-prefix `bucket_prefix` \
    -r/--region `region`
```

Where:
* `project`: the name of the project to have a terraform bootstrap applied
* `bucket_prefix` (optional - use only with caution): Defaults to: `${project}-terraformscaffold"`
* `region` (optional): Defaults to value of the AWS_DEFAULT_REGION environment variable

Aside from the parameter management and other simple bash constructs, the bootstrapping process in the script is three basic steps:

```bash
# Create bootstrap bucket
terraform apply \
  -var "project=${project}" \
  -var "bucket_name=${bucket}" \
  -var "aws_account_id=${aws_account_id}" 

# Setup Terraform Remote State
terraform remote config \
  -backend=S3 -backend-config="region=${region}" \
  -backend-config="bucket=${bucket}" \
  -backend-config="key=${project}/${aws_account_id}/${region}/bootstrap/bootstrap.tfstate"

# Push Terraform Remote State to S3
terraform remote push
```

On the to-do list for future development is to make the bootstrap script check for the presence of an existing bucket and state file, and - if found - to configure it as the remote state prior to application. The current implementation assumes that you will only run bootstrap once, or if you run it a second time, you know what you are doing and have prepared the presence of the state file if it is not still present from the initial run.

### Running

The main scaffold invocation script is bin/terraform.sh. Once a state bucket has been bootstrapped, bin/terraform.sh can be run to apply terraform code. Its usage as of 25/01/2017 is:

```bash
bin/terraform.sh \
  -a/--action        `action` \
  -b/--bucket-prefix `bucket_prefix` \
  -c/--component     `component_name` \
  -e/--environment   `environment` \
  -i/--build-id      `build_id` (optional) \
  -p/--project       `project` \
  -r/--region        `region` \
  -- \
  <additional arguments to forward to the terraform binary call>
```

Where:
* `action`: Terraform action (or pseudo-action) to take, e.g. plan, apply, plan-destroy (runs plan with the -destroy flag), destroy, show
* `bucket_prefix` (optional): Defaults to: `${project_name}-terraformscaffold` - Only for use where a different bucket prefix has been bootstrapped
* `build_id` (optional): Used in conjunction with the plan and apply actions, `build_id` causes the creation and consumption of terraform plan files (.tfplan)
  * When `build_id` is omitted:
    * "Plan" provides normal plan output without generating a plan file
    * "Apply" directly applies the component based on the code and state it is given.
  * When `build_id` is provided:
    * "Plan" creates a plan file with `build_id` as part of the file name, and uploads the plan to the S3 state bucket under a key called "plans/" alongside the corresponding state file
    * "Apply" looks for and downloads the corresponding plan file generated by a plan job, and applies the changes in the plan file
  * It is usual to provide, for example, the Jenkins _$BUILD_ID_ parameter to Plan jobs, and then manually reference that particular Job ID when running a corresponding apply job.
* `component_name`: The name of the terraform component in the components directory to run the `action` against.
* `environment`: The name of the environment the component is to be actioned against, therefore implying the variables file(s) to be included
* `project`: The name of the project being deployed, as per the default bucket-prefix and state file keyspace
* `region` (optional): The AWS region name unique to all components and terraform processes. Defaults to the value of the _AWS_DEFAULT_REGION_ environment variable.
* `additional arguments`: Any arguments provided after "--" will be passed directly to terraform as its own arguments, e.g. allowing the provision of a 'target=value' parameter.
