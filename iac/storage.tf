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

resource "aws_s3_bucket" "udemy" {
  bucket        = "${var.bucket_name}-${local.suffix}"
  force_destroy = var.force_destroy_bucket
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.udemy.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_object" "bucket_zones" {
  for_each = toset([var.prefix_landing_certificate, var.prefix_upstream_certificate, var.prefix_upstream_api])
  bucket   = aws_s3_bucket.udemy.id
  key      = "${each.key}/"
  source   = "/dev/null"

  depends_on = [
    aws_s3_bucket.udemy
  ]
}

resource "aws_s3_bucket_notification" "enable_eventbridge" {
  bucket      = aws_s3_bucket.udemy.id
  eventbridge = true
}