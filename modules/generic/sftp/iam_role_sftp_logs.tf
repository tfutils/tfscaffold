resource "aws_iam_role" "sftp_logs" {
  name               = "${local.csi}-sftp-logs"
  assume_role_policy = data.aws_iam_policy_document.transfer_assumerole.json
}
