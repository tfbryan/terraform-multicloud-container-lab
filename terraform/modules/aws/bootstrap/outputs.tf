output "iam_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = aws_iam_role.github.arn
}

output "iam_role_name" {
  description = "IAM role name for GitHub Actions"
  value       = aws_iam_role.github.name
}

output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_state_bucket_name" {
  description = "State bucket name"
  value       = aws_s3_bucket.tfstate.bucket
}
