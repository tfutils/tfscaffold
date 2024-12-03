output "s3_bucket_id" {
  value = aws_s3_bucket.main.id
}

output "something_sns_topic_arn" {
  value = module.sns_something.topic["arn"]
}
