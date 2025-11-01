variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket for terraform state"
}

variable "table_name" {
  type        = string
  description = "DynamoDB table name for terraform state locking"
  default     = "terraform-locks"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "tags" {
  type    = map(string)
  default = {}
}
