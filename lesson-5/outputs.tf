output "s3_backend_bucket" {
  description = "S3 bucket used for terraform state"
  value       = module.s3_backend.bucket_id
}

output "dynamodb_table_name" {
  description = "DynamoDB table used for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}
