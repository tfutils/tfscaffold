resource "aws_cloudwatch_log_group" "main" {
  name = "/aws/transfer/${aws_cloudformation_stack.transfer_server.outputs.id}"
  tags = local.default_tags
}
