variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "demo-eks-cluster"
}

variable "db_username" {
  default = "postgres"
}

variable "db_password" {
  description = "RDS password"
  sensitive   = true
}