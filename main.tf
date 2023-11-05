module "adobe_analytics_audi_ingestion_glue_job" {
  source = "git@github.com:diogoaurelio/dai-cap-tf-module-aws-glue-job.git"
  enable = true

  create_kms_key = false
  git_repository = var.git_repository

  stage                     = var.stage
  project                   = var.project
  region                    = var.aws_region
  job_name                  = var.glue_job_project_name
  glue_version              = "4.0"
  glue_number_of_workers    = 5
  max_concurrent_runs       = 100
  worker_type               = "G.1X"
  script_bucket             = "barkin-glue-test"
  target_bucket_kms_key_arn = "module.processed_data_lf_bucket.aws_kms_key_arn"
  glue_job_local_path       = "../../../etl/ingest_raw_data/main.py"
  extra_py_files_source_dir = "src/db"
  timeout                   = 15
  enable_additional_policy  = true
  additional_policy         = "data.aws_iam_policy_document.project_glue_job_policy.json"
#   additional_principals     = "[data.aws_iam_session_context.current.issuer_arn]"

  default_arguments = {
    # Glue default arguments
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://barkin-glue-test/glue-job-tmp/"
    "--region"                           = var.aws_region
    "--enable-metrics"                   = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--enable-glue-datacatalog"          = ""
    "--datalake-formats"                 = "hudi"
    "--conf"                             = "spark.serializer=org.apache.spark.serializer.KryoSerializer --conf spark.sql.hive.convertMetastoreParquet=false"

    # Custom job arguments as declared in the spark/glue job python file itself
    "--job_name"        = var.glue_job_project_name
    "--environment"     = var.stage
    "--source_data_uri" = "s3://source"
    "--target_data_uri" = "s3://source" 
    "--hudi_db_name"    = "aws_glue_catalog_database.hudi_database.name"
  }
}