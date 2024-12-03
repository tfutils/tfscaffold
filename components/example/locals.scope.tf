locals {
  component = "example"

  aws = {
    account_id   = var.aws_account_id
    default_tags = local.default_tags
    region       = var.region
    partition    = "aws"
    url_suffix   = "amazonaws.com"
  }

  # Compound Scope Identifier
  unique_id = replace(
    format(
      "%s-%s-%s",
      var.project,
      var.environment,
      local.component,
    ),
    "_",
    "",
  )

  # CSI for use in resources with an account-level namespace, i.e. IAM roles
  unique_id_account = replace(
    format(
      "%s-%s-%s-%s",
      var.project,
      var.environment,
      local.component,
      var.region,
    ),
    "_",
    "",
  )

  # CSI for use in resources with a global namespace, i.e. S3 Buckets
  unique_id_global = replace(
    format(
      "%s-%s-%s-%s-%s",
      var.project,
      var.aws_account_id,
      var.region,
      var.environment,
      local.component,
    ),
    "_",
    "",
  )

  default_tags = merge(
    var.default_tags,
    {
      "Name"                   = local.unique_id
      "tfscaffold:project"     = var.project
      "tfscaffold:environment" = var.environment
      "tfscaffold:component"   = local.component
    },
    var.group != null ? { "tfscaffold:group" = var.group } : {}
  )
}

