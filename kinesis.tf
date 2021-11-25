//  kinesis stream
resource "aws_kinesis_stream" "kinesis" {
  name             = "tf-challenge-kinesis-stream"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

}
resource "aws_kinesis_stream_consumer" "kinesis" {
  name       = "tf-challenge-kinesis-consumer"
  stream_arn = aws_kinesis_stream.kinesis.arn
}
//s3 bucket



// glue database and glue table
resource "aws_glue_catalog_database" "glue" {
  name = "${var.app_name}-glue-database"
}
resource "aws_glue_catalog_table" "glue" {
  name          = "${var.app_name}-glue-table"
  database_name = "${aws_glue_catalog_database.aws_glue_database.name}"

  // Please refere the for more detail configuration of parameters at https://www.terraform.io/docs/providers/aws/r/glue_catalog_table.html
 /*
  parameters {
    classification = "parquet"
  }
*/
  storage_descriptor {
    # location      = "${var.s3_bucket_path}"
    # input_format  = "${var.storage_input_format}"
    # output_format = "${var.storage_output_format}"

    columns = [
      {
        name = "message"
        type = "string"
      }
    ]
  }
}
