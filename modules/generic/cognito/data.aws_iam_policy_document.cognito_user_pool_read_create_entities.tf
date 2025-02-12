data "aws_iam_policy_document" "cognito_user_pool_read_create_entities" {
  statement {
    sid    = "AllowCognitoRead"
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

  statement {
    sid   = "AllowCognitoUserCreate"
    effect = "Allow"

    actions = [
      "cognito-idp:AdminAddUserToGroup",
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminRemoveUserFromGroup",
      "cognito-idp:CreateGroup",
    ]

    resources = [
      aws_cognito_user_pool.main.arn,
    ]
  }
}
