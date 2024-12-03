output "s3_bucket_arn" {
  value = aws_s3_bucket.main.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.main.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.main.id
}

output "s3_bucket_policy" {
  value = data.aws_iam_policy_document.s3_main.json
}

output "s3_kms_key_arn" {
  value = aws_kms_key.s3.arn
}

output "s3_kms_key_id" {
  value = aws_kms_key.s3.id
}

output "s3_kms_key_policy" {
  value = data.aws_iam_policy_document.kms_s3.json
}

