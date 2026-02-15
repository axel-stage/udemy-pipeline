###############################################################################
# module: root
###############################################################################

resource "random_string" "naming" {
  length  = 4
  upper   = false
  numeric = false
  special = false
}

locals {
  suffix = random_string.naming.result
}

resource "aws_cloudwatch_log_group" "lambda_api" {
  name              = "/aws/lambda/${var.api_function_name}"
  retention_in_days = var.lambda_logging_retention
}

resource "aws_cloudwatch_log_group" "lambda_certificate" {
  name              = "/aws/lambda/${var.certificate_function_name}"
  retention_in_days = var.lambda_logging_retention
}

resource "aws_lambda_function" "api" {
  depends_on = [
    aws_cloudwatch_log_group.lambda_api,
    terraform_data.push_api
  ]

  description   = "Handler for Lambda function with fetch api integration"
  function_name = var.api_function_name
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.api_function_name}-${var.api_image_version}"
  memory_size   = var.function_memory_size
  timeout       = var.function_timeout
  architectures = ["x86_64"]

  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }
  environment {
    variables = {
      TEST_VAR = "test"
    }
  }
  tracing_config {
    mode = var.lambda_tracing_config
  }
}

resource "aws_lambda_function" "certificate" {
  depends_on = [
    aws_cloudwatch_log_group.lambda_certificate,
    terraform_data.push_certificate
  ]

  description   = "Handler for Lambda function with certificate scraper integration"
  function_name = var.certificate_function_name
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.certificate_function_name}-${var.certificate_image_version}"
  memory_size   = var.function_memory_size
  timeout       = var.function_timeout
  architectures = ["x86_64"]

  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }
  environment {
    variables = {
      TEST_VAR = "test"
    }
  }
  tracing_config {
    mode = var.lambda_tracing_config
  }
}
