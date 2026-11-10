mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::example-state-bucket"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/github-state"
    }
  }
}

mock_provider "random" {}

run "github_state_access" {
  command = apply

  module {
    source = "../../modules/aws/bootstrap"
  }

  variables {
    name_context = {
      cloud       = { name = "aws", code = "aw" }
      account     = { id = "123456789012", code = "9012" }
      project     = { name = "multicloud", code = "mc" }
      environment = { name = "lab", code = "lab", id = "0" }
      region      = { name = "us-east-1", code = "ue1", id = "1" }
    }
    github_owner = "example"
    github_repo  = "infrastructure"
  }

  override_data {
    target = data.aws_iam_policy_document.github_state
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"*\"}]}"
    }
  }

  assert {
    condition = (
      aws_iam_openid_connect_provider.github.url == "https://token.actions.githubusercontent.com" &&
      toset(aws_iam_openid_connect_provider.github.client_id_list) == toset(["sts.amazonaws.com"]) &&
      length(data.aws_iam_policy_document.github_trust.statement) == 1 &&
      one(data.aws_iam_policy_document.github_trust.statement).effect == "Allow" &&
      toset(one(data.aws_iam_policy_document.github_trust.statement).actions) == toset(["sts:AssumeRoleWithWebIdentity"]) &&
      one(one(data.aws_iam_policy_document.github_trust.statement).principals).type == "Federated" &&
      toset(one(one(data.aws_iam_policy_document.github_trust.statement).principals).identifiers) == toset([aws_iam_openid_connect_provider.github.arn]) &&
      length(one(data.aws_iam_policy_document.github_trust.statement).condition) == 2 &&
      length([for condition in one(data.aws_iam_policy_document.github_trust.statement).condition : condition if condition.test == "StringEquals" && condition.variable == "token.actions.githubusercontent.com:aud" && toset(condition.values) == toset(["sts.amazonaws.com"])]) == 1 &&
      length([for condition in one(data.aws_iam_policy_document.github_trust.statement).condition : condition if condition.test == "StringEquals" && condition.variable == "token.actions.githubusercontent.com:sub" && toset(condition.values) == toset(["repo:example/infrastructure:environment:lab"])]) == 1 &&
      aws_iam_role.github.assume_role_policy == data.aws_iam_policy_document.github_trust.json
    )
    error_message = "The role must trust GitHub OIDC only for the intended audience and repository environment."
  }

  assert {
    condition     = length(data.aws_iam_policy_document.github_state.statement) == 3
    error_message = "The state policy must contain exactly three statements."
  }

  assert {
    condition = length([for statement in data.aws_iam_policy_document.github_state.statement : statement if(
      statement.effect == "Allow" &&
      toset(statement.actions) == toset(["s3:ListBucket"]) &&
      toset(statement.resources) == toset(["arn:aws:s3:::example-state-bucket"]) &&
      length(statement.condition) == 1 &&
      one(statement.condition).test == "StringLike" &&
      one(statement.condition).variable == "s3:prefix" &&
      toset(one(statement.condition).values) == toset(["mc/lab/aws/*"])
    )]) == 1
    error_message = "Bucket listing must be limited to the intended state prefix."
  }

  assert {
    condition = length([for statement in data.aws_iam_policy_document.github_state.statement : statement if(
      statement.effect == "Allow" &&
      toset(statement.actions) == toset(["s3:GetObject", "s3:PutObject"]) &&
      toset(statement.resources) == toset(["arn:aws:s3:::example-state-bucket/mc/lab/aws/platform.tfstate"]) &&
      length(statement.condition) == 0
    )]) == 1
    error_message = "State access must permit only reads and writes to the intended state object."
  }

  assert {
    condition = length([for statement in data.aws_iam_policy_document.github_state.statement : statement if(
      statement.effect == "Allow" &&
      toset(statement.actions) == toset(["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]) &&
      toset(statement.resources) == toset(["arn:aws:s3:::example-state-bucket/mc/lab/aws/platform.tfstate.tflock"]) &&
      length(statement.condition) == 0
    )]) == 1
    error_message = "Lock access must permit reads, writes, and deletion only on the lockfile."
  }

  assert {
    condition     = aws_iam_policy.github.policy == data.aws_iam_policy_document.github_state.json && aws_iam_role_policy_attachment.github.policy_arn == aws_iam_policy.github.arn && aws_iam_role_policy_attachment.github.role == aws_iam_role.github.name
    error_message = "The state document must be attached to the GitHub role through the managed policy."
  }

  assert {
    condition = (
      aws_s3_bucket.tfstate.force_destroy == false &&
      one(aws_s3_bucket_versioning.tfstate.versioning_configuration).status == "Enabled" &&
      one(one(aws_s3_bucket_server_side_encryption_configuration.tfstate.rule).apply_server_side_encryption_by_default).sse_algorithm == "AES256" &&
      aws_s3_bucket_public_access_block.tfstate.block_public_acls &&
      aws_s3_bucket_public_access_block.tfstate.block_public_policy &&
      aws_s3_bucket_public_access_block.tfstate.ignore_public_acls &&
      aws_s3_bucket_public_access_block.tfstate.restrict_public_buckets
    )
    error_message = "State storage must retain versioning, encryption, and public access protections."
  }

  assert {
    condition = (
      length(jsondecode(aws_s3_bucket_policy.tfstate.policy).Statement) == 1 &&
      one(jsondecode(aws_s3_bucket_policy.tfstate.policy).Statement).Effect == "Deny" &&
      one(jsondecode(aws_s3_bucket_policy.tfstate.policy).Statement).Principal == "*" &&
      one(jsondecode(aws_s3_bucket_policy.tfstate.policy).Statement).Action == "s3:*" &&
      toset(one(jsondecode(aws_s3_bucket_policy.tfstate.policy).Statement).Resource) == toset([aws_s3_bucket.tfstate.arn, "${aws_s3_bucket.tfstate.arn}/*"]) &&
      one(jsondecode(aws_s3_bucket_policy.tfstate.policy).Statement).Condition.Bool["aws:SecureTransport"] == "false"
    )
    error_message = "The state bucket policy must deny insecure transport."
  }
}
