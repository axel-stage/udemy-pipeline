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

resource "aws_cloudwatch_log_group" "lambda_scraper" {
  name              = "/aws/lambda/${var.scraper_function_name}"
  retention_in_days = var.lambda_logging_retention
}


# resource "aws_lambda_function" "udemy" {
#   function_name = var.udemy_function_name
#   role          = aws_iam_role.lambda_role.arn
#   package_type  = "Image"
#   image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.udemy_function_name}"
#   memory_size   = var.function_memory_size
#   timeout       = var.function_timeout
#   architectures = ["x86_64"] # "arm64" for Graviton support for better price/performance

#   # image_config {
#   #   entry_point = ["/lambda-entrypoint.sh"]
#   #   command     = ["main.lambda_handler"]
#   # }

#   # Advanced logging configuration
#   logging_config {
#     log_format            = "JSON"
#     application_log_level = "INFO"
#     system_log_level      = "WARN"
#   }

#   environment {
#     variables = {
#       MY_ENV_VAR = "this is env"
#     }
#   }

#   # Ensure log group exists before function
#   depends_on = [
#     aws_cloudwatch_log_group.lambda_logging,
#     docker_registry_image.upload_udemy_web_scraper
#   ]
# }

# resource "aws_lambda_function" "certificate" {
#   function_name = var.certificate_function_name
#   role          = aws_iam_role.lambda_role.arn
#   package_type  = "Image"
#   image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.certificate_function_name}"
#   memory_size   = var.function_memory_size
#   timeout       = var.function_timeout
#   architectures = ["x86_64"]

#   logging_config {
#     log_format            = "JSON"
#     application_log_level = "INFO"
#     system_log_level      = "WARN"
#   }

#   environment {
#     variables = {
#       TEST_VAR = "test"
#     }
#   }

#   depends_on = [
#     aws_cloudwatch_log_group.lambda_certificate,
#     docker_registry_image.upload_udemy_image_scraper
#   ]
# }

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

resource "aws_lambda_function" "scraper" {
  depends_on = [
    aws_cloudwatch_log_group.lambda_scraper,
    terraform_data.push_scraper
  ]

  description   = "Handler for Lambda function with web scraper integration"
  function_name = var.scraper_function_name
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.scraper_function_name}-${var.scraper_image_version}"
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