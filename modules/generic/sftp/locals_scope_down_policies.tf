locals {
  user_scope_down_policies = {
    readonly               = data.aws_iam_policy_document.sftp_user_scope_down_readonly.json
    readwrite            = data.aws_iam_policy_document.sftp_user_scope_down_readwrite.json
    readdelete           = data.aws_iam_policy_document.sftp_user_scope_down_readdelete.json
    writeonly            = data.aws_iam_policy_document.sftp_user_scope_down_writeonly.json
    readonly_no_folder   = data.aws_iam_policy_document.sftp_user_scope_down_readonly_no_folder.json
    readwrite_no_folder  = data.aws_iam_policy_document.sftp_user_scope_down_readwrite_no_folder.json
    writeonly_no_folder  = data.aws_iam_policy_document.sftp_user_scope_down_writeonly_no_folder.json
    readdelete_no_folder = data.aws_iam_policy_document.sftp_user_scope_down_readdelete_no_folder.json
  }
}
