output "bootstrap_tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate_bucket.id
}

output "bootstrap_tfstate_lock_ddbtable_name" {
  value = aws_dynamodb_table.tfstate_lock.name
}
