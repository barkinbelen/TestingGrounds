#
# Project generic vars
#
variable "git_repository" {
  type        = string
  description = "Repository where the infrastructure was deployed from."
  default = "test"
}

variable "stage" {
  description = "Specify to which project this resource belongs, no default value to allow proper validation of project setup"
  type        = string
  default = "test"
}

variable "aws_region" {
  description = "Default Region for Cloud Analytics Platform"
  default     = "eu-central-1"
  type        = string
}

variable "project" {
  description = "Specify to which project this resource belongs"
  default     = "audi-adobe-dp"
  type        = string
}

variable "project_id" {
  description = "project ID for billing"
  default     = "audi-dp"
  type        = string
}

##########################################################################
# S3
##########################################################################

variable "s3_bucket_log" {
  description = "The name of the S3 bucket into which the other buckets log."
  default     = "log-bucket"
  type        = string
}

variable "s3_bucket_source_code" {
  description = "The name of the S3 bucket into source code for lambda and glue is stored."
  default     = "source-code-bucket"
  type        = string
}

variable "s3_bucket_project_name" {
  description = "Bucket for project data"
  default     = "dpt-data"
  type        = string
}

##########################################################################
# GlueJob
##########################################################################

variable "glue_job_project_name" {
  description = "The name of the GlueJob that process file from the S3."
  default     = "fsag-glue-job"
  type        = string
}

variable "wa_number" {
  description = "wa number for billing"
  default     = "N/A"
  type        = string
}

variable "tag_KST" {
  description = "Kosten Stelle, tags from VW"
  default     = "N/A"
  type        = string
}

variable "workflow_timeout_in_minutes" {
  type        = number
  description = "The maximum duration that a Workflow should have. Helps preventing zombie jobs lingering around and draining costs"
  default     = 30
}

##########################################################################
# Lake Formation
##########################################################################

variable "audi_auto_abo_accs_to_share" {
  type        = map(string)
  description = "Account numbers of the dev and prd accouns for Audi Auto Abo. Lake formation resources will be shared here"
  default = {
    dev = "222227446253"
    prd = "849295441054"

  }
}

variable "cap_catalog_account_id" {
  type        = map(string)
  description = "Account IDs of the CAP 2.0 catalog accounts"
  default = {
    dev = "194434162293"
    prd = "213497607727"
  }
}