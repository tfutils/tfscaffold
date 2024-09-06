resource "aws_dynamodb_table" "tfscaffold" {
  name         = var.bucket_name
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.s3.arn
  }

  tags = merge(
    local.default_tags,
    {
      Name = var.bucket_name
    },
  )
}
