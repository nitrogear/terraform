resource "aws_iam_role" "iam_for_lambda" {
  path = "/service-role/"
  name = "${var.naming_prefix}-lambda-rules-executor"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_role_policy_for_lambda" {
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "config:Put*",
        "config:Get*",
        "config:List*",
        "config:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "iam-inactive-user" {
  function_name    = "iam-inactive-user"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "iam-inactive-user.lambda_handler"
  runtime          = "python2.7"
  filename         = "${path.module}/${var.inactive-user-path}"
  source_code_hash = "${base64sha256(file("${path.module}/${var.inactive-user-path}"))}"
  description      = "terraform iam-inactive-user"
}

resource "aws_lambda_function" "iam-unused-keys" {
  function_name    = "iam-unused-keys"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "iam-unused-keys.lambda_handler"
  runtime          = "python2.7"
  filename         = "${path.module}/${var.unused-keys-path}"
  source_code_hash = "${base64sha256(file("${path.module}/${var.unused-keys-path}"))}"
  description      = "terraform iam-unused-keys"
}

resource "aws_lambda_permission" "allow_aws_config_iam-inactive-user" {
  statement_id   = "InactiveUserAllowExecutionFromAWSConfig"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.iam-inactive-user.function_name}"
  principal      = "config.amazonaws.com"
  source_account = "${var.aws_account}"
}

resource "aws_lambda_permission" "allow_aws_config_iam-unused-keys" {
  statement_id   = "UnusedKeysAllowExecutionFromAWSConfig"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.iam-unused-keys.function_name}"
  principal      = "config.amazonaws.com"
  source_account = "${var.aws_account}"
}

resource "aws_config_config_rule" "iam-inactive-user" {
  name = "iam-inactive-user"

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = "${aws_lambda_function.iam-inactive-user.arn}"
    source_detail {
      event_source = "aws.config"
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  scope {
    compliance_resource_types = ["AWS::IAM::User"]
  }

  input_parameters = <<EOF
{ "maxInactiveDays" : "90" }
EOF
}

resource "aws_config_config_rule" "iam-unused-keys" {
  name = "iam-unused-keys"

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = "${aws_lambda_function.iam-unused-keys.arn}"
    source_detail {
      event_source = "aws.config"
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  scope {
    compliance_resource_types = ["AWS::IAM::User"]
  }

  input_parameters = <<EOF
{ "maxInactiveDays" : "90" }
EOF
}
