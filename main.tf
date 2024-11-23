terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# IAM
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_create_upload_url_role" {
  name               = "${var.service_name}-create-upload-url-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  description        = "Lambda role for ${var.service_name}-create-upload-url"
  tags = {
    Service = var.service_name
  }
}

resource "aws_iam_role_policy" "lambda_create_upload_url_role_policy" {
  name = "${var.service_name}CreateUploadUrlPolicy"
  role = aws_iam_role.lambda_create_upload_url_role.id
  # TODO: fix policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Statement0",
        "Effect" : "Allow",
        "Action" : [
          "*",
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

# Lambda
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = "backend/src"
  output_path = "dist/lambda/function_payload.zip"
}

resource "aws_lambda_function" "lambda_create_upload_url" {
  function_name    = "${var.service_name}-create-upload-url"
  filename         = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  description      = "create upload url."
  environment {
    variables = {
      AWS_S3_BUCKET_NAME        = var.aws_s3_bucket
      AWS_PRESIGNED_URL_EXPIRES = var.aws_presigned_url_expires
    }
  }
  handler = "create_upload_url.lambda_handler"
  logging_config {
    log_format            = "JSON"
    application_log_level = var.lambda_application_log_level
    system_log_level      = var.lambda_system_log_level
  }
  memory_size = var.lambda_memory_size
  role        = aws_iam_role.lambda_create_upload_url_role.arn
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout
  tags = {
    Service = var.service_name
  }
}
