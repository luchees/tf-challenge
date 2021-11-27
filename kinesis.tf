//  kinesis stream
resource "aws_kinesis_stream" "kinesis" {
  name             = "${var.app_name}-kinesis-stream"
  shard_count      = 1
  retention_period = 48
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

}
resource "aws_kinesis_stream_consumer" "kinesis" {
  name       = "${var.app_name}-kinesis-consumer"
  stream_arn = aws_kinesis_stream.kinesis.arn
}
//s3 bucket

resource "aws_s3_bucket" "kinesis" {
  bucket = "${var.app_name}-kinesis-bucket"
  acl    = "private"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

// glue database and glue table
resource "aws_glue_catalog_database" "kinesis" {
  name = "${var.app_name}-glue-database"
}
resource "aws_glue_catalog_table" "kinesis" {
  name          = "${var.app_name}-glue-table"
  database_name = aws_glue_catalog_database.kinesis.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
    classification        = "parquet"
  }
  storage_descriptor {
    parameters = {
      typeOfData : "kinesis",
      streamARN : aws_kinesis_stream.kinesis.arn,
    }

    location     = aws_kinesis_stream.kinesis.name
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    columns {
      name = "message"
      type = "string"
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis" {
  name       = "${var.app_name}-firehose-delivery-stream"
  depends_on = [aws_s3_bucket.kinesis]

  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.kinesis.arn
    bucket_arn      = aws_s3_bucket.kinesis.arn
    buffer_size     = 64
    buffer_interval = 60
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesis_firehose_delivery_stream/kinesis"
      log_stream_name = "kinesis"
    }
    compression_format  = "UNCOMPRESSED"
    prefix              = "data=!{timestamp:yyyy}-!{timestamp:MM}-!{timestamp:dd}/"
    error_output_prefix = "error=!{firehose:error-output-type}data=!{timestamp:yyyy}-!{timestamp:MM}-!{timestamp:dd}/"


    data_format_conversion_configuration {
      enabled = true

      input_format_configuration {
        deserializer {
          open_x_json_ser_de {
            case_insensitive = true
          }
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {
            compression = "SNAPPY"
          }
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_database.kinesis.name
        role_arn      = aws_iam_role.kinesis.arn
        table_name    = aws_glue_catalog_table.kinesis.name
        region        = data.aws_region.current.name
      }
    }
  }
}

resource "aws_iam_role" "kinesis" {
  name = "${var.app_name}-stream-consumer-firehose-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}



resource "aws_cloudwatch_log_group" "kinesis" {
  name = "/aws/kinesis_firehose_delivery_stream/kinesis"

  tags = {
    application = var.app_name
  }
}


resource "aws_iam_role_policy" "kinesis" {
  name   = "${var.app_name}-stream-consumer-firehose-inline_policy"
  role   = aws_iam_role.kinesis.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "glue:*",
        "s3:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}