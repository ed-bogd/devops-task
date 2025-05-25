terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# These will be configured later once EKS is created
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# Fetch the EKS cluster details
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

# Fetch the authentication token for the EKS cluster
data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

# Fetch the current AWS account ID
data "aws_caller_identity" "current" {}