variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket for terraform state"
}

variable "table_name" {
  type        = string
  description = "DynamoDB table name for terraform state locking"
  default     = "use_lockfile"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
