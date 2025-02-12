resource "aws_lambda_function" "main" {
  function_name = local.function_name
  description   = local.function_description

  architectures = var.architectures
  handler       = var.function_source_type == "image" ? null : var.function_module_name == null ? var.handler_function_name : "${var.function_module_name}.${var.handler_function_name}"
  layers        = local.layers
  memory_size   = var.memory
  publish       = true
  role          = aws_iam_role.main.arn
  runtime       = var.function_source_type == "image" ? null : var.runtime
  timeout       = var.timeout

  # Destroy will _never_ work on a replicated edge function first time, and there's no reasonable
  # process to do the destroy, and then let it time out, and then wait 24h, and then destroy again.
  # So we just skip the destroy for edge functions, but it does mean a process needed to occasionally
  # clean up the edge functions that are no longer in use.
  skip_destroy = var.edge

  # If function_source_s3_bucket and function_source_s3_key are provided,
  # data source the object to confirm it's there, and depend on the output
  # for bucket, key and version ID information.
  #
  # This is only possible when the s3_bucket is in the same region as the function,
  # otherwise you will need to copy the archive locally using e.g. an AWS CLI call
  # and pass the base64 content from that file into var.function_source_archive_file_path
  s3_bucket         = var.function_source_type == "s3" ? data.aws_s3_object.function_source[0].bucket : null
  s3_key            = var.function_source_type == "s3" ? data.aws_s3_object.function_source[0].key : null
  s3_object_version = var.function_source_type == "s3" ? data.aws_s3_object.function_source[0].version_id : null

  # If (function_source && function_file_extension) or (function_dir) or (function_source_archive_file_path) are provided
  # then we are uploading a zip file from local.archive_path, otherwise it must be the s3 section above
  filename = (
    var.function_source_type == "s3" ? null :
      var.function_source_type == "file" || var.function_source_type == "directory" ? local.archive_path :
        var.function_source_type == "archive" ? var.function_source_archive_file_path :
          null
  )

  # If we havent an S3 bucket or zip content, we're zipping our own file, and need base64sha256 of it
  # If we havent an S3 bucket, but we do have a source archive path, then calculate base64sha256 of the file
  # If we have an S3 bucket, and not zip content, then the version_id of the S3 Object is used as the hash.
  source_code_hash = (
    var.function_source_type == "file" || var.function_source_type == "directory" ? data.archive_file.main[0].output_base64sha256 :
      var.function_source_type == "archive" ? filebase64sha256(var.function_source_archive_file_path) :
        null
  )

  image_uri = var.function_image_uri
  
  dynamic "image_config" {
    for_each = var.function_source_type == "image" && var.function_image_config != null ? [1] : []

    content {
      command           = var.function_image_config["command"]
      entry_point       = var.function_image_config["entry_point"]
      working_directory = var.function_image_config["working_directory"]
    }
  }

  package_type = var.function_source_type == "image" ? "Image" : "Zip"

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []

    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  dynamic "environment" {
    for_each = var.lambda_env_vars != null && length(var.lambda_env_vars) > 0 ? [1] : []

    content {
      variables = var.lambda_env_vars
    }
  }

  tracing_config {
    mode = var.xray_mode
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [1]

    content {
      security_group_ids = var.vpc_config["security_group_ids"]
      subnet_ids         = var.vpc_config["subnet_ids"]
    }
  }

  tags = local.default_tags

  # This depends_on is used to ensure
  # * The log group is in place before the lambda
  #   even exists, so that whenever we have a lambda execution,
  #   a logging destination is guaranteed.
  # * Any local file processing for the function archive is complete
  depends_on = [
    aws_cloudwatch_log_group.main,
    data.archive_file.main,
  ]

  # Le sigh - If we get accidentally trapped into deleting a replicated Edge function
  # the timeout waiting for the delete would be 10 minutes. If we are not deleting
  # a replicated Edge function, then deletion should absolutely take less than 3 minutes.
  timeouts {
    delete = "3m"
  }

  # Le sigh
  provisioner "local-exec" {
    command = "sleep 15"
  }
}
