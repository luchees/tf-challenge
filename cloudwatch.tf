resource "aws_cloudwatch_log_group" "cloudwatch" {
  name = "tf-challenge-message-events"

}

#check role
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch" {
  name            = "tf-challenge-log-subscription"
  role_arn        = aws_iam_role.lambda.arn
  log_group_name  = "/aws/lambda/handler"
  filter_pattern  = "" # empty string for all events
  destination_arn = aws_kinesis_stream.kinesis.arn
  distribution    = "Random" # ByLogStream
}