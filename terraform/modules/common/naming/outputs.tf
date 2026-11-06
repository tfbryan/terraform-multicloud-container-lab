output "resource_name" {
  description = "Formatted resource name"
  value       = local.name
}

output "aws_state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}
