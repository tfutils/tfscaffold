resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json

  depends_on = [
    aws_s3_bucket_public_access_block.main,
  ]
}
