# locals {
#   use_glue_job_s3_key             = var.target_bucket_key_main_glue_job == "" ? "artifact/${module.labels.id}/main.py" : var.target_bucket_key_main_glue_job
#   use_glue_job_extra_files_s3_key = var.target_bucket_key_extra_glue_job_files == "" ? "artifact/${module.labels.id}/extra_py_files.zip" : var.target_bucket_key_extra_glue_job_files
#   kms_key_arn                     = var.create_kms_key ? try(aws_kms_key.cloudwatch_encryption[0].arn, "") : var.kms_key_arn
#   account_id                      = data.aws_caller_identity.current.account_id
# }

data "aws_caller_identity" "current" {}

# module "labels" {
#   #checkov:skip=CKV_TF_1:we use semantic versioning, thereby git hash is **not** the preferred way
#   source          = "git::ssh://cap-tf-module-label/vwdfive/cap-tf-module-label?ref=tags/0.3.0"
#   stage           = var.stage // previously: var.environment
#   project         = var.project
#   name            = var.job_name
#   resource_group  = "glue-job"
#   resources       = ["cloudwatch", "main", "additional", "job-script"]
#   additional_tags = merge(var.tags_kms, var.tags_role)
#   wa_number       = var.wa_number
#   project_id      = var.project_id
#   kst             = var.kst
#   git_repository  = var.git_repository
# }

#
# (Optional) Main glue Job upload taken care by the module
#

# resource "aws_s3_object" "main_glue_job_script" {
#   count = var.enable && var.glue_job_local_path != "" ? 1 : 0

#   bucket      = var.script_bucket
#   key         = local.use_glue_job_s3_key
#   source      = var.glue_job_local_path
#   source_hash = filemd5(var.glue_job_local_path)
# }

#
# (Optional) Additional Glue libs
#

resource "random_string" "track_glue_job_extra_zip_changes" {
  count = var.enable && var.extra_py_files_source_dir != "" ? 1 : 0

  keepers = merge({
    for filename in setunion(
      fileset(var.extra_py_files_source_dir, "**"),
    ) :
    filename => filemd5("${var.extra_py_files_source_dir}/${filename}")
    },
    {
      glue_job_name = "test_job"
    }
  )
  length  = 16
  special = false
}

resource "null_resource" "check_if_there_are_changed_files" {
  count = var.enable && var.extra_py_files_source_dir != "" ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "target_dir=${var.extra_py_files_source_dir} main_branch_name=${var.main_branch_name} /bin/check_for_updated_files.sh"
    interpreter = ["bash", "-c"]
  }
}

data "external" "result_check_for_updated_files" {
  count = var.enable && var.extra_py_files_source_dir != "" ? 1 : 0

  program = ["bash", "cat", "/tmp/files_changed"]

  depends_on = [null_resource.check_if_there_are_changed_files]
}

resource "null_resource" "trigger_new_zip" {
  count = var.enable && var.extra_py_files_source_dir != "" ? 1 : 0

  triggers = {
    # Use the exit_status output variable to trigger this resource if the script is "true."
    if_true = data.external.result_check_for_updated_files[0].result.result == "1" ? timestamp() : null
  }

  depends_on = [data.external.result_check_for_updated_files]
}

data "archive_file" "glue_job_extra_zip" {
  count = var.enable && var.extra_py_files_source_dir != "" ? 1 : 0

  type        = "zip"
  source_dir  = var.extra_py_files_source_dir
  output_path = "${random_string.track_glue_job_extra_zip_changes[count.index].result}_${timestamp()}.zip"
  depends_on = [
    random_string.track_glue_job_extra_zip_changes,
    null_resource.trigger_new_zip
  ]

}

resource "aws_s3_object" "glue_job_extra_zip" {
  count = var.enable && var.extra_py_files_source_dir != "" ? 1 : 0

  bucket = var.script_bucket
  source = data.archive_file.glue_job_extra_zip[count.index].output_path
  key    = "key"

  depends_on = [
    data.archive_file.glue_job_extra_zip,
    random_string.track_glue_job_extra_zip_changes
  ]
}

# #
# # AWS KMS key used to encrypt cloudwatch logs
# #

# resource "aws_kms_key" "cloudwatch_encryption" {
#   count = var.enable && var.create_kms_key ? 1 : 0

#   description             = "Used to encrypt secrets related to ${module.labels.id}"
#   is_enabled              = true
#   key_usage               = "ENCRYPT_DECRYPT"
#   deletion_window_in_days = var.kms_key_deletion_window_in_days
#   enable_key_rotation     = true
#   policy                  = data.aws_iam_policy_document.kms_policy[count.index].json
#   tags                    = module.labels.tags
# }

# resource "aws_kms_alias" "cloudwatch_encryption" {
#   count = var.enable && var.create_kms_key ? 1 : 0

#   name          = join("/", ["alias", module.labels.resource["cloudwatch"]["id"]])
#   target_key_id = aws_kms_key.cloudwatch_encryption[count.index].arn
# }

# data "aws_iam_policy_document" "kms_policy" {
#   count = var.enable && var.create_kms_key ? 1 : 0
#   #checkov:skip=CKV_AWS_109: Ensures that IAM policies do not allow permission management / resource exposure without constraints. The principals do ensure constraints
#   #checkov:skip=CKV_AWS_111: Ensures that IAM policies do not allow write access without constraints. The principals do ensure constraints
#   #checkov:skip=CKV_AWS_356: Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions

#   statement {
#     effect  = "Allow"
#     actions = ["kms:*"]

#     principals {
#       identifiers = compact(concat(["arn:aws:iam::${local.account_id}:root", data.aws_caller_identity.current.arn], var.additional_principals))
#       type        = "AWS"
#     }

#     resources = ["*"]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "kms:ListKeys",
#       "kms:Encrypt*",
#       "kms:Decrypt*",
#       "kms:ReEncrypt*",
#       "kms:Describe*",
#       "kms:GenerateDataKey*",
#     ]

#     resources = [
#       "*",
#     ]

#     principals {
#       identifiers = ["logs.${var.region}.amazonaws.com"]
#       type        = "Service"
#     }
#   }
# }

#
# Glue Job and Security Configuration
#

# resource "aws_glue_security_configuration" "this" {
#   count = var.enable ? 1 : 0

#   name = module.labels.id

#   encryption_configuration {
#     cloudwatch_encryption {
#       cloudwatch_encryption_mode = "SSE-KMS"
#       kms_key_arn                = local.kms_key_arn
#     }

#     job_bookmarks_encryption {
#       job_bookmarks_encryption_mode = "CSE-KMS"
#       kms_key_arn                   = local.kms_key_arn
#     }

#     s3_encryption {
#       s3_encryption_mode = length(var.target_bucket_kms_key_arn) > 0 ? "SSE-KMS" : "DISABLED"
#       kms_key_arn        = length(var.target_bucket_kms_key_arn) > 0 ? var.target_bucket_kms_key_arn : null
#     }
#   }
# }

# locals {
#   # This seemingly complex group of locals tries to allow for arguments such as
#   # --extra-py-files and --additional-python-modules to be injected from inside
#   # and outside the module via the var.default_arguments
#   install_python_module_argument                = length(var.additional_python_modules) != 0 ? map("--additional-python-modules", join(",", var.additional_python_modules)) : {}
#   extra_python_files_value_in_injected_job_args = lookup(var.default_arguments, "--extra-py-files", "")
#   extra_python_files_uploaded_value_by_module   = length(var.extra_py_files_source_dir) > 0 ? "s3://${var.script_bucket}/${local.use_glue_job_extra_files_s3_key}" : ""
#   extra_python_files_referenced_in_module_input = var.target_bucket_key_extra_glue_job_files == "" ? "" : "s3://${var.script_bucket}/${var.target_bucket_key_extra_glue_job_files}"
#   extra_python_files_value                      = join(",", compact([local.extra_python_files_uploaded_value_by_module, local.extra_python_files_value_in_injected_job_args, local.extra_python_files_referenced_in_module_input]))
#   extra_python_files_argument                   = length(local.extra_python_files_value) == 0 ? {} : tomap({ "--extra-py-files" : local.extra_python_files_value })
# }

# #
# # Set retention period to default cloudwatch log groups: /output, /error, and v2
# #
# resource "aws_cloudwatch_log_group" "glue_output" {
#   count = var.enable ? 1 : 0

#   name              = "/aws-glue/jobs/${module.labels.id}-role/${aws_iam_role.this[count.index].name}/output"
#   retention_in_days = 365
#   tags              = module.labels.tags
#   kms_key_id        = local.kms_key_arn
# }

# resource "aws_cloudwatch_log_group" "glue_error" {
#   count = var.enable ? 1 : 0

#   name              = "/aws-glue/jobs/${module.labels.id}-role/${aws_iam_role.this[count.index].name}/error"
#   retention_in_days = 365
#   tags              = module.labels.tags
#   kms_key_id        = local.kms_key_arn
# }

# resource "aws_cloudwatch_log_group" "glue_v2" {
#   count = var.enable ? 1 : 0

#   name              = "/aws-glue/jobs/logs-v2-${aws_glue_security_configuration.this[count.index].name}"
#   retention_in_days = 365
#   tags              = module.labels.tags
#   kms_key_id        = local.kms_key_arn
# }

# resource "aws_glue_job" "this" {
#   count = var.enable ? 1 : 0

#   name                   = module.labels.id
#   description            = "${module.labels.id} ETL processing"
#   role_arn               = aws_iam_role.this[count.index].arn
#   connections            = var.connections
#   max_retries            = var.max_retries
#   timeout                = var.timeout
#   security_configuration = aws_glue_security_configuration.this[count.index].id
#   glue_version           = var.glue_version
#   number_of_workers      = var.command_name == "pythonshell" ? null : var.glue_number_of_workers
#   worker_type            = var.command_name == "pythonshell" ? null : var.worker_type
#   tags                   = module.labels.tags
#   max_capacity           = var.command_name == "pythonshell" ? var.max_capacity : null

#   default_arguments = merge(
#     var.default_arguments,
#     local.install_python_module_argument, // {} or filled in
#     local.extra_python_files_argument,    // {} or filled in
#   )

#   execution_property {
#     max_concurrent_runs = var.max_concurrent_runs
#   }

#   command {
#     name            = var.command_name
#     script_location = "s3://${var.script_bucket}/${local.use_glue_job_s3_key}"
#     python_version  = var.command_name == "pythonshell" ? var.python_version : null
#   }

#   depends_on = [
#     aws_s3_object.main_glue_job_script,
#     aws_s3_object.glue_job_extra_zip
#   ]
# }
