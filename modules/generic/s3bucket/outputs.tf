output "acl" {
  value = var.object_ownership == "BucketOwnerEnforced" || var.acl == null ? "private" : aws_s3_bucket_acl.main[0].acl
}

output "arn" {
  value = aws_s3_bucket.main.arn
}

output "bucket" {
  value = aws_s3_bucket.main.bucket
}

output "bucket_domain_name" {
  value = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.main.bucket_regional_domain_name
}

output "bucket_cors_configuration" {
  value = length(var.cors_rules) > 0 ? aws_s3_bucket_cors_configuration.main[0].id : null
}

output "hosted_zone_id" {
  value = aws_s3_bucket.main.hosted_zone_id
}

output "id" {
  value = aws_s3_bucket.main.id
}

output "lifecycle_configuration_id" {
  value = var.lifecycle_rules == null ? null : aws_s3_bucket_lifecycle_configuration.main[0].rule[*].id
}

output "logging" {
  value = contains(keys(var.bucket_logging_target), "bucket") ? aws_s3_bucket_logging.main[0].id : null
}

output "ownership_controls" {
  value = var.object_ownership == "Unspecified" ? "Unspecified" : aws_s3_bucket_ownership_controls.main[0].id
}

output "policy" {
  value = aws_s3_bucket_policy.main.policy
}

output "public_access_block" {
  value = aws_s3_bucket_public_access_block.main.id
}

output "region" {
  value = aws_s3_bucket.main.region
}

output "server_side_encryption_configuration_id" {
  value = aws_s3_bucket_server_side_encryption_configuration.main.id
}

output "versioning" {
  value = aws_s3_bucket_versioning.main.id
}

# Legacy
output "bucket_ownership_controls" {
  value = aws_s3_bucket_ownership_controls.main
}

##
# All resources completed provisioning / updating
##

output "completion" {
  value = terraform_data.completion.output
}
