terraform {
  backend "s3" {
    bucket         = "fgt-poc-tfbackend-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

data "aws_s3_bucket" "state-bucket" {
 bucket = var.s3_bucket_name 
}

resource "aws_s3_object" "terraform_folder" {
  bucket = data.aws_s3_bucket.state-bucket.id
  key    = "terraform.tfstate"
}