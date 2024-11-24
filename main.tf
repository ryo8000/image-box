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

# API Gateway
resource "aws_api_gateway_rest_api" "image_box_api" {
  name           = "${var.service_name}-api"
  description    = "Image Box API"
  api_key_source = "HEADER"
  endpoint_configuration {
    types = [
      "EDGE"
    ]
  }
}

resource "aws_api_gateway_resource" "create_upload_url" {
  path_part   = "uploadUrl"
  parent_id   = aws_api_gateway_rest_api.image_box_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
}

resource "aws_api_gateway_method" "create_upload_url_post_method" {
  rest_api_id      = aws_api_gateway_rest_api.image_box_api.id
  resource_id      = aws_api_gateway_resource.create_upload_url.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "create_upload_url_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.image_box_api.id
  resource_id             = aws_api_gateway_resource.create_upload_url.id
  http_method             = aws_api_gateway_method.create_upload_url_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_create_upload_url.invoke_arn
}

resource "aws_api_gateway_method" "create_upload_url_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.image_box_api.id
  resource_id      = aws_api_gateway_resource.create_upload_url.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "create_upload_url_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
  resource_id = aws_api_gateway_resource.create_upload_url.id
  http_method = aws_api_gateway_method.create_upload_url_options_method.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "create_upload_url_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
  resource_id = aws_api_gateway_resource.create_upload_url.id
  http_method = aws_api_gateway_method.create_upload_url_options_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "create_upload_url_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
  resource_id = aws_api_gateway_resource.create_upload_url.id
  http_method = aws_api_gateway_method.create_upload_url_options_method.http_method
  status_code = aws_api_gateway_method_response.create_upload_url_options_response_200.status_code
  # TODO
  # response_parameters = {
  #   "method.response.header.Access-Control-Allow-Headers" = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
  #   "method.response.header.Access-Control-Allow-Methods" = "OPTIONS,POST"
  #   "method.response.header.Access-Control-Allow-Origin"  = "*"
  # }
}

resource "aws_api_gateway_resource" "images" {
  path_part   = "images"
  parent_id   = aws_api_gateway_rest_api.image_box_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
}

resource "aws_api_gateway_method" "images_get_method" {
  rest_api_id      = aws_api_gateway_rest_api.image_box_api.id
  resource_id      = aws_api_gateway_resource.images.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "images_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.image_box_api.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.images_get_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_fetch_image_metadata.invoke_arn
}

resource "aws_api_gateway_method" "images_post_method" {
  rest_api_id      = aws_api_gateway_rest_api.image_box_api.id
  resource_id      = aws_api_gateway_resource.images.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "images_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.image_box_api.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.images_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_save_image_metadata.invoke_arn
}

resource "aws_api_gateway_method" "images_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.image_box_api.id
  resource_id      = aws_api_gateway_resource.images.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "images_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.images_options_method.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "images_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.images_options_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "images_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.images_options_method.http_method
  status_code = aws_api_gateway_method_response.images_options_response_200.status_code
  # TODO
  # response_parameters = {
  #   "method.response.header.Access-Control-Allow-Headers" = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
  #   "method.response.header.Access-Control-Allow-Methods" = "GET,OPTIONS,POST"
  #   "method.response.header.Access-Control-Allow-Origin"  = "*"
  # }
}

resource "aws_api_gateway_deployment" "image_box_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.create_upload_url_post_integration,
    aws_api_gateway_integration.create_upload_url_options_integration,
    aws_api_gateway_integration.images_get_integration,
    aws_api_gateway_integration.images_post_integration,
    aws_api_gateway_integration.images_options_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.image_box_api.id
}

resource "aws_api_gateway_stage" "image_box_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.image_box_api.id
  deployment_id = aws_api_gateway_deployment.image_box_api_deployment.id
  stage_name    = "v1"
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

resource "aws_iam_role" "lambda_fetch_image_metadata_role" {
  name               = "${var.service_name}-fetch-image-metadata-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  description        = "Lambda role for ${var.service_name}-fetch-image-metadata"
  tags = {
    Service = var.service_name
  }
}

resource "aws_iam_role_policy" "lambda_fetch_image_metadata_role_policy" {
  name = "${var.service_name}FetchImageMetadataPolicy"
  role = aws_iam_role.lambda_fetch_image_metadata_role.id
  # TODO: fix policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Statement0",
        "Effect" : "Allow",
        "Action" : [
          "*"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_save_image_metadata_role" {
  name               = "${var.service_name}-save-image-metadata-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  description        = "Lambda role for ${var.service_name}-save-image-metadata"
  tags = {
    Service = var.service_name
  }
}

resource "aws_iam_role_policy" "lambda_save_image_metadata_role_policy" {
  name = "${var.service_name}SaveImageMetadataPolicy"
  role = aws_iam_role.lambda_save_image_metadata_role.id
  # TODO: fix policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Statement0",
        "Effect" : "Allow",
        "Action" : [
          "*"
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
      AWS_ORIGIN                = var.aws_origin
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

resource "aws_lambda_permission" "lambda_create_upload_url_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_create_upload_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.image_box_api.execution_arn}/*/${aws_api_gateway_method.create_upload_url_post_method.http_method}${aws_api_gateway_resource.create_upload_url.path}"
}

resource "aws_lambda_function" "lambda_fetch_image_metadata" {
  function_name    = "${var.service_name}-fetch-image-metadata"
  filename         = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  description      = "fetch image metadata."
  environment {
    variables = {
      AWS_ORIGIN               = var.aws_origin
      AWS_IMAGE_METADATA_TABLE = var.aws_image_metadata_table
    }
  }
  handler = "fetch_image_metadata.lambda_handler"
  logging_config {
    log_format            = "JSON"
    application_log_level = var.lambda_application_log_level
    system_log_level      = var.lambda_system_log_level
  }
  memory_size = var.lambda_memory_size
  role        = aws_iam_role.lambda_fetch_image_metadata_role.arn
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout
  tags = {
    Service = var.service_name
  }
}

resource "aws_lambda_permission" "lambda_fetch_image_metadata_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_fetch_image_metadata.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.image_box_api.execution_arn}/*/${aws_api_gateway_method.images_get_method.http_method}${aws_api_gateway_resource.images.path}"
}

resource "aws_lambda_function" "lambda_save_image_metadata" {
  function_name    = "${var.service_name}-save-image-metadata"
  filename         = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  description      = "save image metadata."
  environment {
    variables = {
      AWS_ORIGIN               = var.aws_origin
      AWS_IMAGE_METADATA_TABLE = var.aws_image_metadata_table
    }
  }
  handler = "save_image_metadata.lambda_handler"
  logging_config {
    log_format            = "JSON"
    application_log_level = var.lambda_application_log_level
    system_log_level      = var.lambda_system_log_level
  }
  memory_size = var.lambda_memory_size
  role        = aws_iam_role.lambda_save_image_metadata_role.arn
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout
  tags = {
    Service = var.service_name
  }
}

resource "aws_lambda_permission" "lambda_save_image_metadata_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_save_image_metadata.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.image_box_api.execution_arn}/*/${aws_api_gateway_method.images_post_method.http_method}${aws_api_gateway_resource.images.path}"
}

resource "aws_dynamodb_table" "image_metadata_table" {
  name         = "image-metadata-table"
  hash_key     = "userId"
  range_key    = "fileName"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "fileName"
    type = "S"
  }
}
