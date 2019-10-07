resource "aws_s3_bucket_policy" "tfstate_bucket" {
  bucket = aws_s3_bucket.tfstate_bucket.id
  policy = data.aws_iam_policy_document.tfstate_bucket.json
}
