###############################################################################
# module: root
###############################################################################

###############################################################################
# lambda role

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = var.role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

###############################################################################
# step function state machine role

data "aws_iam_policy_document" "sfsm_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfsm" {
  name = "${var.project}-sfsm-role"
  assume_role_policy = data.aws_iam_policy_document.sfsm_assume_role.json
}

resource "aws_iam_policy" "sfsm" {
  name        = "sfsm-policy"
  description = "step function state machine policy"
  policy      = templatefile(
    "template/policy_sfsm.tftpl", {
      #sfsm_arn    = aws_sfn_state_machine.this.arn
      bucket_arn = aws_s3_bucket.udemy.arn
      lambda_api = aws_lambda_function.api.arn
      lambda_certificate = aws_lambda_function.certificate.arn
      lambda_pipeline = aws_lambda_function.pipeline.arn
    }
  )
}

resource "aws_iam_role_policy_attachment" "sfsm" {
  role       = aws_iam_role.sfsm.name
  policy_arn = aws_iam_policy.sfsm.arn
}


###############################################################################
# eventbridge role

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge" {
  name = "${var.project}-eventbridge-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

resource "aws_iam_policy" "eventbridge" {
  name        = "eventbridge-policy"
  description = "eventbridge policy"
  policy      = templatefile(
    "template/policy_eventbridge.tftpl", {
      sfsm_arn    = aws_sfn_state_machine.this.arn
    }
  )
}

resource "aws_iam_role_policy_attachment" "eventbridge" {
  role       = aws_iam_role.eventbridge.name
  policy_arn = aws_iam_policy.eventbridge.arn
}