locals {
  topic_name            = coalesce(var.topic_name, local.unique_id)
  topic_display_name    = coalesce(var.display_name, local.topic_name)
  topic_policy_required = ( length(var.iam_policy_documents) > 0 || length(var.publishing_service_principals) > 0 )
}

