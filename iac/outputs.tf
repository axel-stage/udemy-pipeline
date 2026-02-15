###############################################################################
# module: root
###############################################################################
# dev
output "cwd_path" {
  description = "path"
  value       = path.cwd
}

###############################################################################
# project

output "bucket_id" {
  description = "Bucket ID"
  value       = aws_s3_bucket.udemy.id
}

output "role_arn" {
  description = "Lambda role arn"
  value       = aws_iam_role.lambda_role.arn
}

output "api_function_name" {
  description = "Name of the Lambda function."
  value       = var.api_function_name
}

output "certificate_function_name" {
  description = "Name of the Lambda function."
  value       = var.certificate_function_name
}

# output "scraper_function_name" {
#   description = "Name of the Lambda function."
#   value       = var.scraper_function_name
# }
