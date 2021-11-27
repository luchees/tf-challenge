resource "aws_cloudwatch_log_group" "cloudwatch" {
  name = "${var.app_name}-message-events"

}

//TODO Role best practice
resource "aws_iam_role" "cloudwatch" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = aws_iam_policy.cloudwatch.arn
  role       = aws_iam_role.cloudwatch.name
}

resource "aws_iam_policy" "cloudwatch" {
  policy = data.aws_iam_policy_document.cloudwatch.json
}
#fix region and lambda name
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid       = "AllowKinesisPermissions"
    effect    = "Allow"
    resources = ["arn:aws:kinesis:*"]

    actions = [
      "kinesis:*"
    ]
  }
}
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch" {
  name            = "${var.app_name}-log-subscription"
  role_arn        = aws_iam_role.cloudwatch.arn
  log_group_name  = "/aws/lambda/${var.app_name}-lambda"
  filter_pattern  = "[...,loglevel=INFO ,message]"
  destination_arn = aws_kinesis_stream.kinesis.arn
  distribution    = "Random" # ByLogStream
}