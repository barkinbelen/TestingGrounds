variable "enable" {
  description = "Whether the resources in this module should be created or not"
  type        = bool
  default     = true
}

variable "stage" {
  description = "Environment the crawler is created within such as dev or prod"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "wa_number" {
  description = "WA Number of the project"
  type        = string
  default     = "Not Set"
}

variable "git_repository" {
  description = "Git repository from which the resources are deployed"
  type        = string
}

variable "project_id" {
  description = "Project ID"
  type        = string
  default     = "Not Set"
}

variable "kst" {
  description = "Cost center of the stack"
  type        = string
  default     = "Not Set"
}

variable "region" {
  description = "The region the job will be deployed in"
  type        = string
}

variable "job_name" {
  description = "Name of the Glue Job to be run"
  type        = string
}

variable "script_bucket" {
  description = "S3 bucket of the Glue job where glue job script and (optionally) extra python files are OR will be uploaded. They'll be uploaded when var.glue_job_local_path/var.extra_py_files_source_dir is provided"
  type        = string
}

variable "target_bucket_key_main_glue_job" {
  description = "[Optional] Path, inside the bucket, where the file should be uploaded to OR where the file already is (uploaded by some logic external to the present module)"
  type        = string
  default     = ""
}

variable "target_bucket_key_extra_glue_job_files" {
  description = "[Optional] Path, inside the bucket, where the file should be uploaded to OR where the file already is (uploaded by some logic external to the present module)"
  type        = string
  default     = ""
}

variable "target_bucket_kms_key_arn" {
  description = "KMS Key used to encrypt the data when writing to an S3 bucket"
  type        = string
}

variable "default_arguments" {
  description = "Default arguments such as the job languages"
  type        = map(string)
  default     = {}
}

variable "connections" {
  description = "List of connections to be used in the job"
  type        = list(string)
  default     = []
}

variable "command_name" {
  description = "Defines whether spark or script is used: glueetl, pythonshell, gluestreaming"
  type        = string
  default     = "glueetl"
}

variable "max_concurrent_runs" {
  description = "The maximum number of concurrent runs allowed for a job"
  type        = number
  default     = 1
}

variable "max_retries" {
  description = "Maximum amount of retries"
  type        = number
  default     = 0
}

variable "timeout" {
  description = "Timeout in minutes"
  type        = number
  default     = 2880
}

variable "kms_key_deletion_window_in_days" {
  description = "Deletion window for the kms key"
  type        = number
  default     = 7
}

variable "tags_kms" {
  description = "Default Tags for the Security Configuration KMS Key"
  type        = map(string)
  default     = {}
}

variable "tags_role" {
  description = "Default Tags for the IAM role"
  type        = map(string)
  default     = {}
}

variable "enable_additional_policy" {
  description = "Whether to attach an additional policy."
  type        = bool
  default     = false
}

variable "additional_policy" {
  description = "Additional IAM Policy to attach to the newly created role"
  type        = string
  default     = ""
}

variable "extra_py_files_source_dir" {
  description = "[Optional] Local path of the source directory with extra py files. Relative to where the module will be instantiated."
  type        = string
  default     = ""
}

variable "main_branch_name" {
  description = "The name of the core branch into where all PRs are merged. Usually named as 'main' or 'master'"
  type        = string
  default     = "main"
}

variable "additional_python_modules" {
  description = <<EOF
    List of libraries and corresponding version which Glue will install before running the job. Example: ["scikit-learn==0.21.3", "pandas==10.10.10"]
  EOF
  type        = list(string)
  default     = []
}

variable "glue_version" {
  description = "Choose between Glue 1.0 or 2.0 versions. Differences here: https://docs.aws.amazon.com/glue/latest/dg/reduced-start-times-spark-etl-jobs.html"
  type        = string
  default     = "1.0"
}

variable "python_version" {
  description = "Version of python used to start job"
  type        = string
  default     = "3.9"
}

variable "glue_number_of_workers" {
  description = "The number of workers of a defined workerType that are allocated when a job runs"
  type        = number
  default     = 5
}

variable "worker_type" {
  description = "The type of predefined worker that is allocated when a job runs. Accepts a value of Standard, G.1X, or G.2X"
  type        = string
  default     = "G.1X"
}

# variable "additional_principals" {
#   description = "Additional ARNs of principals to add to the KMS Key Policy"
#   type        = list(string)
#   default     = []
# }

variable "max_capacity" {
  description = "The maximum number of AWS Glue data processing units (DPUs) that can be allocated when this job runs. Required when pythonshell is set, accept either 0.0625 or 1.0."
  type        = string
  default     = "0.0625"
}

variable "glue_job_local_path" {
  description = "[Optional] Path to glue job .py file to be used upload to the provided bucket. Relative to where the module is instantiated"
  type        = string
  default     = ""
}

########################
# KMS key variables
########################

variable "create_kms_key" {
  description = "Whether to create a KMS key or not. IMPORTANT: If the module has been used before, set this variable to 'true' to not loose the previously created KMS key and the encrypted data. If the module is used for the first time set this variable to `false` and manage the KMS key outside of this module and provide the KMS key ARN"
  type        = bool
}

variable "kms_key_arn" {
  description = "The KMS key ARN to use for the encrypted resources within this module. Make sure that the cloudwatch logs service is allowed to use the key (https://github.com/vwdfive/cap-tf-module-aws-kms-key/tree/main/examples/complex)"
  type        = string
  default     = ""
}