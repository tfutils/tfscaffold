data "aws_iam_policy_document" "cognito_user_pool_manage" {
  statement {
    sid    = "AllowManageCognito"
    effect = "Allow"

    actions = [
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminListGroupsForUser",
      "cognito-idp:AdminListUserAuthEvents",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:DescribeUserPool",
      "cognito-idp:ListGroups",
      "cognito-idp:ListUsers",
      "cognito-idp:ListUsersInGroup",
    ]

    resources = [
      aws_cognito_user_pool.main.arn,
    ]
  }
}
