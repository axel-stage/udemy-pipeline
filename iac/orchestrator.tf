###############################################################################
# module: root
###############################################################################

resource "aws_sfn_state_machine" "this" {
  name     = "udemy-state-machine"
  role_arn = aws_iam_role.sfsm.arn

  definition = <<EOF
{
  "Comment": "Udemy batch orchestrator",
  "StartAt": "ProcessBatch",
  "States": {
    "ProcessBatch": {
      "Type": "Map",
      "ItemReader": {
        "Resource": "arn:aws:states:::s3:getObject",
        "Parameters": {
          "Bucket.$": "$.detail.bucket.name",
          "Key.$": "$.detail.object.key"
        },
        "ReaderConfig": {
          "InputType": "JSON"
        }
      },
      "ItemProcessor": {
        "ProcessorConfig": {
          "Mode": "DISTRIBUTED",
          "ExecutionType": "STANDARD"
        },
        "StartAt": "ProcessCertificate",
        "States": {
          "ProcessCertificate": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "FunctionName": "${aws_lambda_function.certificate.arn}",
              "Payload": {
                "CERTIFICATE_ID.$": "$.certificate_id",
                "COURSE_SLUG.$": "$.course_slug",
                "BUCKET_NAME": "${aws_s3_bucket.udemy.id}",
                "PREFIX_LANDING_CERTIFICATE": "${var.prefix_landing_certificate}",
                "PREFIX_UPSTREAM_CERTIFICATE": "${var.prefix_upstream_certificate}"
              }
            },
            "ResultPath": "$.certificate_result",
            "Retry": [
              {
                "ErrorEquals": ["States.ALL"],
                "IntervalSeconds": 2,
                "MaxAttempts": 2,
                "BackoffRate": 2
              }
            ],
            "Catch": [
              {
                "ErrorEquals": ["States.ALL"],
                "ResultPath": "$.certificate_error",
                "Next": "MarkCertificateFailed"
              }
            ],
            "Next": "CallAPI"
          },

          "MarkCertificateFailed": {
            "Type": "Pass",
            "Parameters": {
              "status": "CERTIFICATE_FAILED",
              "certificate_id.$": "$.certificate_id",
              "course_slug.$": "$.course_slug",
              "error.$": "$.certificate_error"
            },
            "Next": "CallAPI"
          },

          "CallAPI": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "FunctionName": "${aws_lambda_function.api.arn}",
              "Payload": {
                "CERTIFICATE_ID.$": "$.certificate_id",
                "COURSE_SLUG.$": "$.course_slug",
                "BUCKET_NAME": "${aws_s3_bucket.udemy.id}",
                "PREFIX_UPSTREAM_API": "${var.prefix_upstream_api}"
              }
            },
            "ResultPath": "$.api_result",
            "Retry": [
              {
                "ErrorEquals": ["States.ALL"],
                "IntervalSeconds": 3,
                "MaxAttempts": 2,
                "BackoffRate": 2
              }
            ],
            "Catch": [
              {
                "ErrorEquals": ["States.ALL"],
                "ResultPath": "$.api_error",
                "Next": "MarkAPIFailed"
              }
            ],
            "End": true
          },

          "MarkAPIFailed": {
            "Type": "Pass",
            "Parameters": {
              "status": "API_FAILED",
              "certificate_id.$": "$.certificate_id",
              "course_slug.$": "$.course_slug",
              "error.$": "$.api_error"
            },
            "End": true
          }
        }
      },
      "MaxConcurrency": 10,
      "Next": "ETLPipeline"
    },

    "ETLPipeline": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${aws_lambda_function.pipeline.arn}",
        "Payload": {
          "batch_status": "COMPLETED",
          "BUCKET_NAME": "${aws_s3_bucket.udemy.id}",
          "TABLE_NAME": "${aws_dynamodb_table.udemy_course.name}",
          "PREFIX_UPSTREAM_CERTIFICATE": "${var.prefix_upstream_certificate}",
          "PREFIX_UPSTREAM_API": "${var.prefix_upstream_api}"
        }
      },
      "End": true
    }
  }
}
EOF

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfsm.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}
