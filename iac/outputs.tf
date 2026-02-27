###############################################################################
# module: root
###############################################################################

###############################################################################
# project

output "bucket_id" {
  description = "Bucket ID"
  value       = aws_s3_bucket.udemy.id
}

output "lambda_role_arn" {
  description = "Lambda role arn"
  value       = aws_iam_role.lambda.arn
}

output "sfsm_role_arn" {
  description = "Lambda role arn"
  value       = aws_iam_role.sfsm.arn
}

output "api_function_name" {
  description = "Name of the Lambda function."
  value       = var.api_function_name
}

output "certificate_function_name" {
  description = "Name of the Lambda function."
  value       = var.certificate_function_name
}

output "pipeline_function_name" {
  description = "Name of the Lambda function."
  value       = var.pipeline_function_name
}
