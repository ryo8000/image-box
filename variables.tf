variable "service_name" {
  default     = "image-box"
  description = "this service name"
  type        = string
}

variable "app_s3_bucket" {
  default     = ""
  description = "AWS S3 bucket"
  type        = string
}

variable "app_region" {
  default     = ""
  description = "AWS region to deploy products."
  type        = string
}

variable "app_presigned_url_expires" {
  default     = 60
  description = "1 minute"
  type        = number
}

variable "app_origin" {
  default     = ""
  description = "Access-Control-Allow-Origin"
  type        = string
}

variable "app_image_metadata_table" {
  default     = "image-metadata-table"
  description = "table name"
  type        = string
}

variable "lambda_application_log_level" {
  default     = "INFO"
  description = "lambda application log level"
  type        = string
}

variable "lambda_system_log_level" {
  default     = "INFO"
  description = "lambda system log level"
  type        = string
}

variable "lambda_memory_size" {
  default     = 128
  description = "lambda memory size"
  type        = number
}

variable "lambda_runtime" {
  default     = "python3.13"
  description = "lambda runtime"
  type        = string
}

variable "lambda_timeout" {
  default     = 5
  description = "lambda timeout"
  type        = number
}

variable "lambda_event_batch_size" {
  default     = 10
  description = "lambda event batch size"
  type        = number
}
