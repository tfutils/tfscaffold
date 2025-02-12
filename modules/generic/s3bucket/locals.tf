locals {
  bucket_name = var.bucket_name != null ? var.bucket_name : local.unique_id_global
}
