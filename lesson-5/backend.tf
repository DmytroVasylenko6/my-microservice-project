terraform {
  backend "s3" {
    bucket         = "REPLACE_ME_UNIQUE_BUCKET_NAME"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
