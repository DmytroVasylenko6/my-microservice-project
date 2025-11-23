output "bucket_id" {
  description = "S3 bucket id for terraform state"
  value       = aws_s3_bucket.tf_state.id
}

output "bucket_arn" {
  description = "S3 bucket arn"
  value       = aws_s3_bucket.tf_state.arn
}

output "bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.tf_state.bucket_domain_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name used for locking"
  value       = aws_dynamodb_table.tf_lock.name
}

