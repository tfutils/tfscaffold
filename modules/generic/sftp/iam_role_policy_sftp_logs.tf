resource "aws_iam_role_policy" "sftp_logs" {
  name   = "${local.csi}-sftp-logs"
  role   = aws_iam_role.sftp_logs.id
  policy = data.aws_iam_policy_document.sftp_logs_write.json
}
