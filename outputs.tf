output "lambda_create_upload_url" {
  value = aws_lambda_function.lambda_create_upload_url.qualified_arn
}

output "lambda_fetch_image_metadata" {
  value = aws_lambda_function.lambda_fetch_image_metadata.qualified_arn
}
