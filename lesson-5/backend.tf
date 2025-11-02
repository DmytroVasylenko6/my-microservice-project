terraform {
  backend "s3" {
    bucket         = "picsio-bucket-626bb381c1ab654dc35b8adb-us-east-1"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "use_lockfile"
    encrypt        = true
  }
}
