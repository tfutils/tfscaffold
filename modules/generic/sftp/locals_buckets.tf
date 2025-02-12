locals {
  buckets = values(var.users)[*].bucket
}
