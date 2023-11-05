# Terraform Module: AWS GLUE JOB

**NOTE:** When using this module for the first time, **inject the KMS key** instead of making the module create one. The
feature to create a KMS key is just still enabled to ensure backwards compatibility.

```hcl-terraform
module "glue_job" {
  source = "git::ssh://git@cap-tf-module-aws-glue-job/vwdfive/cap-tf-module-aws-glue-job.git?ref=tags/0.1.0"
  ...
}
```

## Requirements

Currently, the CAP project uses different SSH Deploy Keys, each unique to its module repo. For this reason, referencing to the current module from any of the CAP related projects, the developer needs to setup an entry in the SSH Config to create a unique alias for the module.

## Current usage

### SSH Config

In the scenario where the Private SSH Deploy Key is stored in ~/.ssh/cap-tf-module-aws-glue-job, then the entry in the SSH config file (typically in ~/.ssh/config) could look like:

```
Host cap-tf-module-aws-glue-job
  HostName github.com
  User git
  IdentityFile ~/.ssh/cap-tf-module-aws-glue-job
```

Doing so, will let any application using SSH (including Terraform) refer to the module with with cap-tf-module-aws-glue-job as hostname instead of github.com. For example, the developer could now download the repository with:

```
git clone cap-tf-module-aws-glue-job:vwdfive/cap-tf-module-aws-glue-job.git
```

### Module usage

The current implementation of glue-job modules in the original `cap-consumer-ap` repository contains 1x module for glue-job.
(notice usage of the repo path of the module + tag version)

```hcl-terraform
module "transform_raw_data" {
  source = "git::ssh://cap-tf-module-aws-glue-job/vwdfive/cap-tf-module-aws-glue-job?ref=tags/<tag-version>"
  enable = true

  stage                     = var.stage
  project                   = var.project
  account_id                = data.aws_caller_identity.current.account_id
  region                    = var.aws_region
  job_name                  = "transform-raw-data"
  glue_version              = "2.0"
  glue_number_of_workers    = var.glue_workers[var.stage]
  worker_type               = "G.1X"
  script_bucket             = module.prm_glue_scripts_bucket.s3_bucket
  target_bucket_kms_key_arn = module.prm_glue_scripts_bucket.aws_kms_key_arn
  glue_job_local_path       = "../../../etl/structure_vehicle_data/main.py"
  # not mandatory, just in case there are libraries which need to be used
  extra_py_files_source_dir = "../../../etl/structure_vehicle_data/"
  timeout                   = 90
  enable_additional_policy  = true
  additional_policy         = data.aws_iam_policy_document.some_policy_document.json

  default_arguments = {
    # default arguments accepted by glue
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://your-stage-bucket-used-for-tmp-files/glue-job-tmp/"
    "--region"                           = var.aws_region
    "--enable-metrics"                   = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.log_group.name

    # job specific arguments
    "--process_days"             = "10"
  }
}
```
In cloudwatch logs, there are 3 Log Groups used/created by a Glue Job and they are created by AWS without any retention period and are not managed by Terraform. In this version of the module, we try to anticipate the names of those log groups, by creating them in advance and give them a retention time. The way AWS has implemented AWS Glue jobs logging when they contain security configurations (as is the case for the Glue jobs at CAP), prevents the developer from defining the exact name of the Cloudwatch Log Groups that the Glue jobs will use/create. Instead, it optionally accepts some input, which they used as a part of the name of the Cloudwatch Log Groups that are going to be created. In this version, since we are anticipating the names of log groups that glue job will create, this will "trick" the Glue Job into realizing it doesn't need to create the log groups and use instead the ones that are already there with the name that it wanted to use in the first place.
> **Please note:** This is the first time we are pre-creating the log groups for the Glue Job, so to avoid naming conflicts when upgrading from an older version, we slightly change the names of the role so that the new log groups won't collide with preexisting ones which are unmanaged by Terraform (surprisingly enough, AWS uses the IAM Role Name to compose the name of the to-be-created log groups).

# Module Spec

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | git::ssh://cap-tf-module-label/vwdfive/cap-tf-module-label | tags/0.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.glue_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.glue_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.glue_v2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_glue_job.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job) | resource |
| [aws_glue_security_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_security_configuration) | resource |
| [aws_iam_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.cloudwatch_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudwatch_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_object.main_glue_job_script](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [null_resource.check_if_there_are_changed_files](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [random_string.track_glue_job_extra_zip_changes](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [archive_file.glue_job_extra_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policy"></a> [additional\_policy](#input\_additional\_policy) | Additional IAM Policy to attach to the newly created role | `string` | `""` | no |
| <a name="input_additional_principals"></a> [additional\_principals](#input\_additional\_principals) | Additional ARNs of principals to add to the KMS Key Policy | `list(string)` | `[]` | no |
| <a name="input_additional_python_modules"></a> [additional\_python\_modules](#input\_additional\_python\_modules) | List of libraries and corresponding version which Glue will install before running the job. Example: ["scikit-learn==0.21.3", "pandas==10.10.10"] | `list(string)` | `[]` | no |
| <a name="input_command_name"></a> [command\_name](#input\_command\_name) | Defines whether spark or script is used: glueetl, pythonshell, gluestreaming | `string` | `"glueetl"` | no |
| <a name="input_connections"></a> [connections](#input\_connections) | List of connections to be used in the job | `list(string)` | `[]` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether to create a KMS key or not. IMPORTANT: If the module has been used before, set this variable to 'true' to not loose the previously created KMS key and the encrypted data. If the module is used for the first time set this variable to `false` and manage the KMS key outside of this module and provide the KMS key ARN | `bool` | n/a | yes |
| <a name="input_default_arguments"></a> [default\_arguments](#input\_default\_arguments) | Default arguments such as the job languages | `map(string)` | `{}` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Whether the resources in this module should be created or not | `bool` | `true` | no |
| <a name="input_enable_additional_policy"></a> [enable\_additional\_policy](#input\_enable\_additional\_policy) | Whether to attach an additional policy. | `bool` | `false` | no |
| <a name="input_extra_py_files_source_dir"></a> [extra\_py\_files\_source\_dir](#input\_extra\_py\_files\_source\_dir) | [Optional] Local path of the source directory with extra py files. Relative to where the module will be instantiated. | `string` | `""` | no |
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | Git repository from which the resources are deployed | `string` | n/a | yes |
| <a name="input_glue_job_local_path"></a> [glue\_job\_local\_path](#input\_glue\_job\_local\_path) | [Optional] Path to glue job .py file to be used upload to the provided bucket. Relative to where the module is instantiated | `string` | `""` | no |
| <a name="input_glue_number_of_workers"></a> [glue\_number\_of\_workers](#input\_glue\_number\_of\_workers) | The number of workers of a defined workerType that are allocated when a job runs | `number` | `5` | no |
| <a name="input_glue_version"></a> [glue\_version](#input\_glue\_version) | Choose between Glue 1.0 or 2.0 versions. Differences here: https://docs.aws.amazon.com/glue/latest/dg/reduced-start-times-spark-etl-jobs.html | `string` | `"1.0"` | no |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | Name of the Glue Job to be run | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The KMS key ARN to use for the encrypted resources within this module. Make sure that the cloudwatch logs service is allowed to use the key (https://github.com/vwdfive/cap-tf-module-aws-kms-key/tree/main/examples/complex) | `string` | `""` | no |
| <a name="input_kms_key_deletion_window_in_days"></a> [kms\_key\_deletion\_window\_in\_days](#input\_kms\_key\_deletion\_window\_in\_days) | Deletion window for the kms key | `number` | `7` | no |
| <a name="input_kst"></a> [kst](#input\_kst) | Cost center of the stack | `string` | `"Not Set"` | no |
| <a name="input_main_branch_name"></a> [main\_branch\_name](#input\_main\_branch\_name) | The name of the core branch into where all PRs are merged. Usually named as 'main' or 'master' | `string` | `"main"` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum number of AWS Glue data processing units (DPUs) that can be allocated when this job runs. Required when pythonshell is set, accept either 0.0625 or 1.0. | `string` | `"0.0625"` | no |
| <a name="input_max_concurrent_runs"></a> [max\_concurrent\_runs](#input\_max\_concurrent\_runs) | The maximum number of concurrent runs allowed for a job | `number` | `1` | no |
| <a name="input_max_retries"></a> [max\_retries](#input\_max\_retries) | Maximum amount of retries | `number` | `0` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID | `string` | `"Not Set"` | no |
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | Version of python used to start job | `string` | `"3.9"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region the job will be deployed in | `string` | n/a | yes |
| <a name="input_script_bucket"></a> [script\_bucket](#input\_script\_bucket) | S3 bucket of the Glue job where glue job script and (optionally) extra python files are OR will be uploaded. They'll be uploaded when var.glue\_job\_local\_path/var.extra\_py\_files\_source\_dir is provided | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Environment the crawler is created within such as dev or prod | `string` | n/a | yes |
| <a name="input_tags_kms"></a> [tags\_kms](#input\_tags\_kms) | Default Tags for the Security Configuration KMS Key | `map(string)` | `{}` | no |
| <a name="input_tags_role"></a> [tags\_role](#input\_tags\_role) | Default Tags for the IAM role | `map(string)` | `{}` | no |
| <a name="input_target_bucket_key_extra_glue_job_files"></a> [target\_bucket\_key\_extra\_glue\_job\_files](#input\_target\_bucket\_key\_extra\_glue\_job\_files) | [Optional] Path, inside the bucket, where the file should be uploaded to OR where the file already is (uploaded by some logic external to the present module) | `string` | `""` | no |
| <a name="input_target_bucket_key_main_glue_job"></a> [target\_bucket\_key\_main\_glue\_job](#input\_target\_bucket\_key\_main\_glue\_job) | [Optional] Path, inside the bucket, where the file should be uploaded to OR where the file already is (uploaded by some logic external to the present module) | `string` | `""` | no |
| <a name="input_target_bucket_kms_key_arn"></a> [target\_bucket\_kms\_key\_arn](#input\_target\_bucket\_kms\_key\_arn) | KMS Key used to encrypt the data when writing to an S3 bucket | `string` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in minutes | `number` | `2880` | no |
| <a name="input_wa_number"></a> [wa\_number](#input\_wa\_number) | WA Number of the project | `string` | `"Not Set"` | no |
| <a name="input_worker_type"></a> [worker\_type](#input\_worker\_type) | The type of predefined worker that is allocated when a job runs. Accepts a value of Standard, G.1X, or G.2X | `string` | `"G.1X"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_job_arn"></a> [aws\_glue\_job\_arn](#output\_aws\_glue\_job\_arn) | n/a |
| <a name="output_aws_glue_job_id"></a> [aws\_glue\_job\_id](#output\_aws\_glue\_job\_id) | n/a |
| <a name="output_aws_glue_job_name"></a> [aws\_glue\_job\_name](#output\_aws\_glue\_job\_name) | n/a |
| <a name="output_aws_glue_job_sec_config_name"></a> [aws\_glue\_job\_sec\_config\_name](#output\_aws\_glue\_job\_sec\_config\_name) | n/a |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | n/a |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | n/a |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | n/a |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | n/a |
<!-- END_TF_DOCS -->
