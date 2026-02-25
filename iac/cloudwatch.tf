###############################################################################
# module: root
###############################################################################

resource "aws_cloudwatch_log_group" "lambda_api" {
  name              = "/aws/lambda/${var.api_function_name}"
  retention_in_days = var.lambda_logging_retention
}
resource "aws_cloudwatch_log_group" "lambda_certificate" {
  name              = "/aws/lambda/${var.certificate_function_name}"
  retention_in_days = var.lambda_logging_retention
}
resource "aws_cloudwatch_log_group" "lambda_pipeline" {
  name              = "/aws/lambda/${var.pipeline_function_name}"
  retention_in_days = var.lambda_logging_retention
}

resource "aws_cloudwatch_log_group" "sfsm" {
  name_prefix       = "/aws/vendedlogs/states/UdemyStateMachine-"
  retention_in_days = var.lambda_logging_retention
}

###############################################################################
# EventBridge

resource "aws_cloudwatch_event_rule" "udemy_batch" {
  name        = "trigger-udemy-batch-rule"
  description = "Trigger Step Function for udemy batch processing"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.udemy.id}"]
    },
    "object": {
      "key": [{
        "prefix": "batch-trigger/"
      }]
    }
  }
}

EOF
}

resource "aws_cloudwatch_event_target" "step_function_target" {
  rule      = aws_cloudwatch_event_rule.udemy_batch.name
  target_id = "StepFunctionTarget"
  arn       = aws_sfn_state_machine.this.arn
  role_arn  = aws_iam_role.eventbridge.arn
}