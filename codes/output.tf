# output "kms_key_arn" {
#   value = var.create_kms_key ? try(aws_kms_key.cloudwatch_encryption[0].arn, "") : var.kms_key_arn
# }

# output "kms_key_id" {
#   value = var.create_kms_key ? try(aws_kms_key.cloudwatch_encryption[0].id, "") : ""
# }

# output "iam_role_arn" {
#   value = try(aws_iam_role.this[0].arn, "")
# }

# output "iam_role_name" {
#   value = try(aws_iam_role.this[0].name, "")
# }

# output "aws_glue_job_id" {
#   value = try(aws_glue_job.this[0].id, "")
# }

# output "aws_glue_job_name" {
#   value = try(aws_glue_job.this[0].name, "")
# }

# output "aws_glue_job_arn" {
#   value = try(aws_glue_job.this[0].arn, "")
# }

# output "enabled" {
#   value = var.enable
# }

# output "aws_glue_job_sec_config_name" {
#   value = try(aws_glue_security_configuration.this[0].name, "")
# }
