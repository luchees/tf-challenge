# define sqs policy
resource "aws_sqs_queue" "queue_deadletter" {
  name                      = "${var.app_name}-queue-deadletter"
  message_retention_seconds = 1209600 # 14 days

}

# define sqs policy for lambda
resource "aws_sqs_queue" "queue" {
  name                       = "${var.app_name}-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600 # 4 days
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_deadletter.arn
    maxReceiveCount     = 3
  })
  depends_on = [aws_sqs_queue.queue_deadletter]
}
