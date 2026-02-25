data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "this" {}

resource "local_file" "env" {
  content = templatefile("template/env.tftpl", {
    table_name = aws_dynamodb_table.udemy_course.name
    bucket_name = aws_s3_bucket.udemy.id
    prefix_landing_certificate = var.prefix_landing_certificate
    prefix_upstream_certificate = var.prefix_upstream_certificate
    prefix_upstream_api = var.prefix_upstream_api
    api_function_name = var.api_function_name
    certificate_function_name = var.certificate_function_name
    pipeline_function_name = var.pipeline_function_name
  })
  filename = "../${path.module}/.env"
}