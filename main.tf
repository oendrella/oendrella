#ECR repo

resource "aws_ecr_repository" "nginx" {
  name = "nginx-app"
}
#fetch VPC details
data "aws_vpc" "default" {
  default = true
}

#fetch subnet details
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  # Optional: filter for private subnets
  tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"
  vpc_id          = data.aws_vpc.default.id
  subnets         = data.aws_subnets.private.ids

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}


# IAM Role for Kaniko Pod (IRSA)
data "aws_iam_policy_document" "kaniko_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.cluster_oidc_issuer_url]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:default:kaniko-sa"]
    }
  }
}

resource "aws_iam_role" "kaniko" {
  name               = "kaniko-role"
  assume_role_policy = data.aws_iam_policy_document.kaniko_assume_role.json
}

resource "aws_iam_role_policy" "kaniko_ecr_policy" {
  name   = "kaniko-ecr"
  role   = aws_iam_role.kaniko.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

# Kubernetes Service Account with IRSA
resource "kubernetes_service_account" "kaniko_sa" {
  metadata {
    name      = "kaniko-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.kaniko.arn
    }
  }
}