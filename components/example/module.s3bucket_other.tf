module "s3bucket_bestpractice" {
  source = "../../modules/generic/s3bucket"

  aws = local.aws

  unique_ids = {
    global = "${local.unique_id_global}-bestpractice"
  }

  force_destroy = false

  kms_key_arn = module.kms_s3.key_arn
}
