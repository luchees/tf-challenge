variable "app_name" {
  description = "Name of the application"
  default     = "tf-challenge"
}
data "aws_region" "current" {
  provider = aws.region
}