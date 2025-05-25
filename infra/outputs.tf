output "region" {
  value       = var.aws_region
  description = "AWS region used for deployment"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the created VPC"
}

output "subnet_ids" {
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.private_1.id, aws_subnet.private_2.id]
  description = "IDs of public and private subnets"
}

output "eks_admin_access_key_id" {
  value       = aws_iam_access_key.eks_admin.id
  description = "Access key ID for the eks-admin user"
}

output "eks_admin_secret_access_key" {
  value       = aws_iam_access_key.eks_admin.secret
  description = "Secret access key for the eks-admin user"
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "OIDC issuer URL for IRSA"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "IAM OIDC provider ARN"
}

output "atlantis_url" {
  description = "Public LoadBalancer DNS for Atlantis"
  value       = try(data.kubernetes_service.atlantis.status[0].load_balancer[0].ingress[0].hostname, "")
}

