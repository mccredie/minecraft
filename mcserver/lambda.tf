
variable "server_prefix" {}
variable "domain_name" {}
variable "hostedzone_id" {}

resource "aws_cloudwatch_event_rule" "trigger_lifecycle_hook" {
  name        = "EC2LifecycleAction"
  description = "Respond to EC2 lifecycle actions"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "EC2 Instance-launch Lifecycle Action",
    "EC2 Instance-terminate Lifecycle Action"
  ],
  "resources": [
    "${aws_autoscaling_group.bar.arn}"
  ]
}
PATTERN
}


data "archive_file" "lifecycle_hook_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lifecycle_handler.py"
  output_path = "${path.module}/out/lifecycle_handler_lambda.zip"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lifecycle_hook.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_lifecycle_hook.arn
}

resource "aws_lambda_function" "lifecycle_hook" {
  filename      = "${path.module}/out/lifecycle_handler_lambda.zip"
  function_name = "lifecyle_hook"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lifecycle_handler.handler"
  runtime       = "python3.8"

  environment {
    variables = {
      HOSTED_ZONE_ID = var.hostedzone_id
      DOMAIN_NAME = "${var.server_prefix}.${var.domain_name}"
    }
  }
}

resource "aws_cloudwatch_event_target" "lifecycle_hook" {
  arn       = aws_lambda_function.lifecycle_hook.arn
  rule      = aws_cloudwatch_event_rule.trigger_lifecycle_hook.name
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy" "lambda_execution_role_policy" {
  name = "lambda_execution_role_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EnableCloudwatchLogging",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-west-2:594180171374:log-group:/aws/lambda/lifecycle_event:*"
            ]
        },
        {
            "Sid": "AllowAutoScalingLifecycleHookComplete",
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction"
            ],
            "Resource": [
                "${aws_autoscaling_group.bar.arn}"
            ]
        },
        {
            "Sid": "AllowQueryEC2Instance",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceAttribute"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowModifyDNSResources",
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${var.hostedzone_id}"
            ]
        }
    ]
}
EOF
}

output "server_domain" {
  value = "${var.server_prefix}.${var.domain_name}"
}
