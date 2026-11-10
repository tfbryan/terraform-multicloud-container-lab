data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "github_trust" {
  statement {
    sid    = "GitHubActionsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_subjects
      ]
    }
  }
}

data "aws_iam_policy_document" "github_state" {
  statement {
    sid    = "GitHubActionsPipeline"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.tfstate.arn
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "${local.state_key_prefix}/*"
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.tfstate.arn}/${local.state_key}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.tfstate.arn}/${local.state_lock_key}"
    ]
  }
}
