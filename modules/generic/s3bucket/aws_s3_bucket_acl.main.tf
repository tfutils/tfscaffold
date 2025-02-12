resource "aws_s3_bucket_acl" "main" {
  count = var.object_ownership == "BucketOwnerEnforced" || var.acl == null ? 0 : 1

  bucket = aws_s3_bucket.main.id
  acl    = var.acl
}
