resource "terraform_data" "completion" {
  input = "BUCKET_CHANGE_COMPLETED"

  triggers_replace = md5(jsonencode([
    aws_s3_bucket_accelerate_configuration.main,
    aws_s3_bucket_acl.main,
    aws_s3_bucket_cors_configuration.main,
    aws_s3_bucket_lifecycle_configuration.main,
    aws_s3_bucket_logging.main,
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket_policy.main,
    aws_s3_bucket_public_access_block.main,
    aws_s3_bucket_server_side_encryption_configuration.main,
    aws_s3_bucket_versioning.main,
    aws_s3_bucket.main,
  ]))

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]

    command = "sleep 5"
  }
}
