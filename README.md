# TFScaffold

A framework for controlling multi-environment multi-component Terraform-managed AWS infrastructure.

## Origin

TFScaffold has been developed by the [TFUtils](https://github.com/tfutils) people, some of them I worked with.
I've been using it since 2017, however, many of the features introduced did not fit my purposes that's why I cut them off, kept only what I found important for myself and added some new bits. It will stay as a fork forever :)

## Changelog

### 1.1.0 (07/10/2019)

 * TFState S3 Bucket encryption enabled
 * TFState S3 Bucket nonSSL requests denied
 * TFState Lock DDB Table encryption enabled

### 1.0.0 (25/09/2019)

 * Removed unsued features from original TFScaffold v. 1.4.2 by TFUtils
 * Added DDB support for state locking
 * Applied TF v. 0.12 syntax to bootstrap code
 * Added component/module templates (TF v. 0.12)
 * Improved console output readability

## Usage

TFScaffold has been developed to be run on Linux-powered operating systems, mainly tested on RedHat-family distros.
As a Mac user, I want to be able to run TFScaffold locally this is why a simple Docker configuration has been developed that allows running it within a Docker container. [Here](https://github.com/sebolabs/docker-tf) is where the Docker-powereed TFScaffold Runner can be found.

An additional tool, that is built into the TFScaffold and simplifies people's lives when working with Terraform, is [TFEnv](https://github.com/tfutils/tfenv).

### Bootstrapping

```bash
bin/terraform.sh \
  --bootstrap \
  -p/--project `project` \
  -b/--bucket-prefix `bucket_prefix` \
  -r/--region `region` \
  -a/--action plan/apply
```

Where:
* `project`: the name of the project to have a terraform bootstrap applied
* `bucket_prefix` (optional - use only with caution): Defaults to: `${project}-terraformscaffold"`
* `region` (optional): Defaults to value of the AWS_DEFAULT_REGION environment variable

### Running

The terraformscaffold script is invoked as bin/terraform.sh. Once a state bucket has been bootstrapped, bin/terraform.sh can be run to apply terraform code.

```bash
bin/terraform.sh \
  -a/--action        `action` \
  -b/--bucket-prefix `bucket_prefix` \
  -c/--component     `component_name` \
  -e/--environment   `environment` \
  -g/--group         `group` (optional) \
  -i/--build-id      `build_id` (optional) \
  -p/--project       `project` \
  -r/--region        `region` \
  -- \
  <additional arguments to forward to the terraform binary call>
```

Where:
* `action`: Terraform action (or pseudo-action) to take, e.g. plan, apply, plan-destroy (runs plan with the -destroy flag), destroy, show
* `bucket_prefix` (optional): Defaults to: `${project_name}-terraformscaffold` - Only for use where a different bucket prefix has been bootstrapped
* `component_name`: The name of the terraform component in the components directory to run the `action` against.
* `environment`: The name of the environment the component is to be actioned against, therefore implying the variables file(s) to be included
* `group` (optional): The name of the group to which the environment belongs, permitting the use of a group tfvars file as a "meta-environment" shared by more than one environment
* `project`: The name of the project being deployed, as per the default bucket-prefix and state file keyspace
* `region` (optional): The AWS region name unique to all components and terraform processes. Defaults to the value of the _AWS_DEFAULT_REGION_ environment variable.
* `additional arguments`: Any arguments provided after "--" will be passed directly to terraform as its own arguments, e.g. allowing the provision of a 'target=value' parameter.

### TF compatibility

Latest version checked: `0.12.10`

---
---

## From TFScaffold authors...

### Overview

TFScaffold consists of a Terraform wrapper bash script, a bootstrap script and a set of directories providing the locations to store terraform code and variables.

| Thing	| Things about the Thing |
|-------|------------------------|
| bin/terraform.sh | The TFScaffold script |
| bootstrap/ | The bootstrap terraform code used for creating the TFScaffold S3 bucket. |
| components/ |	The location for terraform "components". Terraform code intended to be run directly as a root module. |
| etc/ | The location for environment-specific terraform variables files. |
| lib/ | Optional useful libraries, such as Jenkins pipeline groovy script |
| modules/ | The optional location for terraform modules called by components |
| plugin-cache/ | The default directory used for caching plugin downloads |

### Concepts & Assumptions

#### Multi-Component Environment Concept

The Scaffold is built around the concept that a logical "environment" may consist of any number of independent components across independent AWS accounts. What provides consistency across these components, and therefore defines the environment, are the variables shared between the components. For example, the CIDR block defining a primary VPC for a production environment is needed by the component that creates the VPC, it may also be needed by components in other VPCs or accounts. All components in a production enviroment are likely to share the "envirornment" variable value "production".

Scaffold achieves this by maintaining variables specific to an environment in the file _etc/env_{region}_{environment}.tfvars_, and then providing those variables as inputs to all components run for that environment. Any variables not required by a component are safely ignored, but all components have visibility of all variables for an environment.

Important Note: Variables in the Env and Versions variables files are not merged. You cannot, for example, define the same map variable in both files and have the keys in each definition merged into a resulting set. When a variable is defined more than once, the last one terraform evaluates takes precedence and overrides any previously encountered definition. To prevent unexpected consequences, never define variable values in more than one place.

#### State File Location Consistency and Referencing

Scaffold uses AWS S3 for storage of tfstate files. The bucket and location are specifically defined to be predictable to organise their storage and permit the use of terraform_remote_state resources. Any scaffold component can reliably refer to the S3 location of the state file for another component and depend upon the outputs provided. The naming convention is: _s3://${project}-terraformscaffold-${aws_account_id}-${aws_region}/${project}/${aws_account_id}/${aws_region}/${environment}/${component}.tfstate_. Each functional scaffold S3 bucket will only therefore contain content within the keyspace _/${project}/${aws_account_id}/${aws_region}_ as these are unique to the bucket as well as all contents. The reason for the use of this keyspace is to permit the aggregation of state files from multiple bucket into a master bucket for backup or read-only review purposes. All scaffold buckets relevant to a person or organisation could be safely synchronised to a single bucket without fear of keyspace overlap.

#### Variables Files: Environment & Versions

Scaffold provides a logical separation of several types of environment variable:
 * Global variables
 * Region-scoped global variables
 * Group variables
 * Static environment variables
 * Frequently-changing versions variables

This seperation is purely logical, not functional. It makes no functional difference in which file a variable lives, or even whether a versions variables file exists; but it provides the capacity to seperate out mostly static variables that define the construction of the environment from variables that could change on each apply providing new AMI IDs, or dockerised application versions or database snapshot IDs when recreating development and testing databases.

#### AWS Credentials

TFScaffold does not provide any mechanism for running terraform across multiple AWS accounts simultaneously, storing state files in a different account to the account being modified or any other functionality that would require Scaffold to intelligently manage AWS credentials. After extensive research and development it has become apparant that, despite some features available in terraform to handle more than one AWS account and the use of IAM roles, the features are not sufficiently mature or flexible to allow their application in a generic form.

Therefore, to ensure widest possible reach and capability of Scaffold, it requires that a specific set of AWS credentials be provided to it at invocation. These credentials must have the necessary access to read and write to the bootstrapped S3 state file bucket, and to create/modify/destroy the AWS resources being controlled via terraform.

Credentials can be provided in any of the standard mechanisms provided by the Boto search path, for example, EC2 Instance Profiles, an _~/.aws/credentials_ file or _AWS_ACCESS_KEY_ID_ and _AWS_SECRET_ACCESS_KEY_ environment variables.

If you want to make use of instance profiles, MFA tokens, AWS STS, Cross Account Roles or other fantastic IAM trickery, the recommended practice is to use a static access key or instance profile to call AWS STS using the AWS CLI tools, and then assign the temporary credentials that are generated to the AWS credential environment variables so that terraform can make use of them. This is done externally to Scaffold and would normally be integrated into a Jenkins job as a step to perform to prepare the environment before calling Scaffold.
