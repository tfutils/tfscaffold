resource "aws_dynamodb_table" "tfstate_lock" {
  name           = var.bucket_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    local.default_tags,
    map(
      "Name", "TFScaffold TFState lock table",
    ),
  )
}
