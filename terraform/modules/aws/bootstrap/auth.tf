# GitHub role
module "aws_github_role_name" {
  source = "../../common/naming"

  name_context = var.name_context
  type         = "role"
  descriptor   = "cicd"
  global       = true
}

resource "aws_iam_role" "github" {
  name                 = module.aws_github_role_name.resource_name
  assume_role_policy   = data.aws_iam_policy_document.github_trust.json
  max_session_duration = var.max_session_duration

  tags = {
    Name = module.aws_github_role_name.resource_name
  }
}

# GitHub Policy
module "aws_github_policy_name" {
  source = "../../common/naming"

  name_context = var.name_context
  type         = "policy"
  descriptor   = "cicd"
  global       = true
}

resource "aws_iam_policy" "github" {

  name        = module.aws_github_policy_name.resource_name
  description = "Permissions for GitHub Actions pipeline deployments"

  policy = data.aws_iam_policy_document.github_state.json

  tags = {
    Name = module.aws_github_policy_name.resource_name
  }
}

resource "aws_iam_role_policy_attachment" "github" {

  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github.arn
}
