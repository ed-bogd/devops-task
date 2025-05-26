module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.36.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  subnet_ids      = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.public_1.id, aws_subnet.public_2.id]
  vpc_id          = aws_vpc.main.id

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
  
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["${var.my_ip_address}/0"] # Not safe

  # Define node groups
  eks_managed_node_groups = {
    default = {
      desired_size = var.desired_capacity
      min_size     = var.min_size
      max_size     = var.max_size

      instance_types = [var.instance_type]
      subnet_ids     = [aws_subnet.private_1.id, aws_subnet.private_2.id]

      # IAM role for the node group
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      tags = {
        Name = "${var.project_name}-eks-node"
      }
    }
  }

  # Addons configuration
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true }
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

# Mapping IAM users and roles to Kubernetes RBAC
module "eks_aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.36.0"
  manage_aws_auth_configmap = true
  
  aws_auth_users = [
    {
      userarn  = aws_iam_user.eks_admin.arn
      username = "eks-admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_read_only.arn
      username = "eks-read-only"
      groups   = ["view"]
    }
  ]
}
