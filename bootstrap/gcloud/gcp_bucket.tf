resource "google_storage_bucket" "bucket" {
   name = "${var.bucket_name}"
   project = "${var.project}"
 
   location = "${var.region}"
   storage_class = "REGIONAL"
 
   force_destroy = "false"
 
   versioning { enabled = "true" }
 
 
   # This does not use default tag map merging because bootstrapping is special
   # You should use default tag map merging elsewhere
#   labels = {
#     "Name"        = "Terraform Scaffold State File Bucket for account ${var.account_id} in region ${var.region}"
#     "Environment" = "${var.environment}"
#     "Account"     = "${var.account_id}"
#     "Component"   = "${var.component}"
#   }
 }

