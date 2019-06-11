/* resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  force_destroy = "false"

  versioning {
    enabled = "true"
  }

  lifecycle_rule {
    prefix  = "/"
    enabled = "true"

    noncurrent_version_transition {
      days          = "30"
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = "60"
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = "90"
    }
  }

  # This does not use default tag map merging because bootstrapping is special
  # You should use default tag map merging elsewhere
  tags {
    "Name"        = "Terraform Scaffold State File Bucket for account ${var.aws_account_id} in region ${var.region}"
    "Environment" = "${var.environment}"
    "Project"     = "${var.project}"
    "Component"   = "${var.component}"
    "Account"     = "${var.aws_account_id}"
  }
}
*/

resource "azurerm_resource_group" "container" {
  name     = "${lower(var.bucket_name)}"
  location = "${var.region}"
}

resource "azurerm_storage_account" "container" {
  name                     = "${var.project}${var.region}tfstate"
  resource_group_name      = "${azurerm_resource_group.container.name}"
  location                 = "${var.region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "${lower(var.bucket_name)}"
  resource_group_name   = "${azurerm_resource_group.container.name}"
  storage_account_name  = "${azurerm_storage_account.container.name}"
  container_access_type = "private"
}
