# data "aws_iam_policy_document" "assume_role" {
#   count = var.enable ? 1 : 0

#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       identifiers = ["glue.amazonaws.com"]
#       type        = "Service"
#     }
#   }
# }

# resource "aws_iam_role" "this" {
#   count = var.enable ? 1 : 0

#   name               = module.labels.id
#   assume_role_policy = data.aws_iam_policy_document.assume_role[count.index].json
#   tags               = module.labels.tags
# }

# data "aws_iam_policy_document" "this" {
#   count = var.enable ? 1 : 0

#   statement {
#     sid    = "AllResourceActions"
#     effect = "Allow"
#     #checkov:skip=CKV_AWS_111:Skip reason - Resource not known before apply
#     #checkov:skip=CKV_AWS_356
#     actions = [
#       "s3:ListAllMyBuckets",
#       "ec2:DescribeVpcEndpoints",
#       "ec2:DescribeRouteTables",
#       "ec2:DescribeNetworkInterfaces",
#       "ec2:DescribeSecurityGroups",
#       "ec2:DescribeSubnets",
#       "glue:CreateScript",
#       "glue:CreateWorkflow",
#       "glue:GetClassifier",
#       "glue:GetClassifiers",
#       "glue:GetDataflowGraph",
#       "glue:GetJobs",
#       "glue:GetMapping",
#       "glue:GetPlan",
#       "glue:GetSecurityConfiguration",
#       "glue:GetSecurityConfigurations",
#       "glue:GetTriggers",
#       "glue:ListJobs",
#       "glue:ListTriggers",
#       "glue:ListWorkflows"
#     ]

#     resources = ["*"]
#   }

#   statement {
#     sid    = "EC2Actions"
#     effect = "Allow"
#     actions = [
#       "ec2:CreateNetworkInterface",
#       "ec2:CreateTags",
#       "ec2:DeleteNetworkInterface",
#       "ec2:DeleteTags",
#       "ec2:DescribeVpcAttribute"
#     ]
#     resources = [
#       "arn:aws:ec2:*:*:network-interface/*",
#       "arn:aws:ec2:*:*:security-group/*",
#       "arn:aws:ec2:*:*:subnet/*",
#       "arn:aws:ec2:*:*:instance/*",
#       "arn:aws:ec2:*:*:vpc/*"
#     ]
#   }

#   statement {
#     sid    = "IamActions"
#     effect = "Allow"
#     actions = [
#       "iam:ListRolePolicies",
#       "iam:GetRole",
#       "iam:GetRolePolicy"
#     ]
#     resources = [
#       "arn:aws:iam::*:role/*"
#     ]
#   }

#   statement {
#     sid    = "S3Actions"
#     effect = "Allow"
#     actions = [
#       "s3:GetBucketAcl",
#       "s3:GetBucketLocation",
#       "s3:ListBucket"
#     ]
#     resources = [
#       "arn:aws:s3:::*"
#     ]
#   }

#   statement {
#     sid    = "GlueActions"
#     effect = "Allow"
#     actions = [
#       "glue:GetConnections",                   #catalog, connection
#       "glue:GetDataCatalogEncryptionSettings", #catalog
#       "glue:GetTableVersions",                 #catalog, database, table
#       "glue:GetPartitions",                    #catalog, database, table
#       "glue:GetWorkflowRunProperties",         #workflow
#       "glue:DeleteTableVersion",               #catalog, database, table
#       "glue:StopTrigger",                      #trigger
#       "glue:StartTrigger",                     #trigger
#       "glue:GetCatalogImportStatus",           #catalog
#       "glue:GetTableVersion",                  #catalog, database, table
#       "glue:GetTrigger",                       #trigger
#       "glue:GetConnection",                    #catalog, connection
#       "glue:GetUserDefinedFunction",           #catalog, database, userdefinedfunction
#       "glue:GetJobRun",                        #job
#       "glue:UpdateJob",                        #job
#       "glue:StartWorkflowRun",                 #workflow
#       "glue:GetUserDefinedFunctions",          #catalog, database, userdefinedfunction
#       "glue:GetTables",                        #catalog, database, table
#       "glue:GetWorkflowRun",                   #workflow
#       "glue:BatchGetPartition",                #catalog, database, table
#       "glue:BatchStopJobRun",                  #job
#       "glue:GetDatabases",                     #catalog, database
#       "glue:GetTags",                          #blueprint, crawler, devendpoint, job, trigger, workflow
#       "glue:GetTable",                         #catalog, database, table
#       "glue:GetDatabase",                      #catalog, database
#       "glue:GetPartition",                     #catalog, database, table
#       "glue:BatchGetWorkflows",                #workflow
#       "glue:BatchGetTriggers",                 #trigger
#       "glue:BatchGetJobs",                     #job
#       "glue:StartJobRun",                      #job
#       "glue:GetJob",                           #job
#       "glue:GetWorkflow",                      #workflow
#       "glue:GetJobRuns",                       #job
#     ]

#     resources = [
#       "arn:aws:glue:${var.region}:${local.account_id}:blueprint/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:catalog",
#       "arn:aws:glue:${var.region}:${local.account_id}:crawler/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:connection/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:database/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:devEndpoint/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:job/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:table/*/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:trigger/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:userDefinedFunction/*",
#       "arn:aws:glue:${var.region}:${local.account_id}:workflow/*"
#     ]
#   }

#   statement {
#     sid    = "CloudwatchLogsActions"
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#       "logs:PutLogEvents",
#       "logs:AssociateKmsKey",
#     ]
#     resources = [
#       "arn:aws:logs:${var.region}:${local.account_id}:log-group:*"
#     ]
#   }

#   statement {
#     sid    = "CloudwatchActions"
#     effect = "Allow"
#     actions = [
#       "cloudwatch:PutMetricData",
#     ]
#     resources = ["*"]
#   }

#   statement {
#     sid     = "AllowGlueToReadScriptsBucket"
#     effect  = "Allow"
#     actions = ["s3:Get*", "s3:List*", "kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey", "kms:Describe"]
#     resources = compact([
#       var.target_bucket_kms_key_arn,
#       "arn:aws:s3:::${var.script_bucket}",
#       "arn:aws:s3:::${var.script_bucket}/*"
#     ])
#   }

#   statement {
#     sid    = "KmsActions"
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
#       local.kms_key_arn
#     ]
#   }
# }

# resource "aws_iam_role_policy" "this" {
#   count = var.enable ? 1 : 0

#   name   = module.labels.resource["main"]["id"]
#   policy = data.aws_iam_policy_document.this[count.index].json
#   role   = aws_iam_role.this[count.index].name
# }

# resource "aws_iam_policy" "additional" {
#   count  = var.enable_additional_policy && var.enable ? 1 : 0
#   name   = module.labels.resource["additional"]["id"]
#   policy = var.additional_policy
# }

# resource "aws_iam_role_policy_attachment" "additional" {
#   count      = var.enable_additional_policy && var.enable ? 1 : 0
#   role       = aws_iam_role.this[count.index].name
#   policy_arn = aws_iam_policy.additional[count.index].arn
# }
