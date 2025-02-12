data "archive_file" "main" {
  # If function source isnt in s3, or provided as zip content, we neeed to zip
  # something from the local filesystem
  count = var.function_source_type == "directory" || var.function_source_type == "file" ? 1 : 0

  type        = "zip"
  output_path = local.archive_path

  source_dir = var.function_source_type == "directory" ? "${path.root}/${var.function_dir}" : null

  dynamic "source" {
    for_each = var.function_source_type == "file" ? [1] : []

    content {
      content  = var.function_source
      filename = "${var.function_module_name}.${var.function_file_extension}"
    }
  }
}
