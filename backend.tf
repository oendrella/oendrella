terraform {
  backend "s3" {
    bucket         = "terraformbucket2398 "
    key            = "eks-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}