resource "aws_kms_key" "s3" {
  description             = "tfscaffold Bootstrap S3 Bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key_s3.json

  # This does not use default tag map merging because bootstrapping is special
  # You should use default tag map merging elsewhere
  tags = merge(
    local.default_tags,
    {
      Name = "tfscaffold Bootstrap S3 Bucket"
    }
  )
}
