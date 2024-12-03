locals {
  feedback_config = {
    application = {
      failure_role_arn = try(coalesce(var.application_failure_feedback_role_arn, var.default_failure_feedback_role_arn, var.default_feedback_role_arn), null)
      success_role_arn = try(coalesce(var.application_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null)

      success_sample_rate = ( try(coalesce(var.application_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null) == null
        ? null
        : try(coalesce(var.application_success_feedback_sample_rate, var.default_success_feedback_sample_rate), null)
      )
    }

    firehose = {
      failure_role_arn = try(coalesce(var.firehose_failure_feedback_role_arn, var.default_failure_feedback_role_arn, var.default_feedback_role_arn), null)
      success_role_arn = try(coalesce(var.firehose_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null)

      success_sample_rate = ( try(coalesce(var.firehose_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null) == null
        ? null
        : try(coalesce(var.firehose_success_feedback_sample_rate, var.default_success_feedback_sample_rate), null)
      )
    }

    http = {
      failure_role_arn = try(coalesce(var.http_failure_feedback_role_arn, var.default_failure_feedback_role_arn, var.default_feedback_role_arn), null)
      success_role_arn = try(coalesce(var.http_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null)

      success_sample_rate = ( try(coalesce(var.http_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null) == null
        ? null
        : try(coalesce(var.http_success_feedback_sample_rate, var.default_success_feedback_sample_rate), null)
      )
    }

    lambda = {
      failure_role_arn = try(coalesce(var.lambda_failure_feedback_role_arn, var.default_failure_feedback_role_arn, var.default_feedback_role_arn), null)
      success_role_arn = try(coalesce(var.lambda_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null)

      success_sample_rate = ( try(coalesce(var.lambda_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null) == null
        ? null
        : try(coalesce(var.lambda_success_feedback_sample_rate, var.default_success_feedback_sample_rate), null)
      )
    }

    sqs = {
      failure_role_arn = try(coalesce(var.sqs_failure_feedback_role_arn, var.default_failure_feedback_role_arn, var.default_feedback_role_arn), null)
      success_role_arn = try(coalesce(var.sqs_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null)

      success_sample_rate = ( try(coalesce(var.sqs_success_feedback_role_arn, var.default_success_feedback_role_arn, var.default_feedback_role_arn), null) == null
        ? null
        : try(coalesce(var.sqs_success_feedback_sample_rate, var.default_success_feedback_sample_rate), null)
      )
    }
  }
}
