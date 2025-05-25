# Create a Kubernetes namespace for Atlantis
resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = "atlantis"
  }
}

# Create Kubernetes secret for sensitive values
resource "kubernetes_secret" "atlantis_secrets" {
  metadata {
    name      = "atlantis-secrets"
    namespace = kubernetes_namespace.atlantis.metadata[0].name
  }

  data = {
    github-token     = var.github_token
    webhook-secret   = var.atlantis_webhook_secret
  }

  type = "Opaque"
}

# Bind Atlantis service account to cluster-admin (simplest approach)
resource "kubernetes_cluster_role_binding" "atlantis" {
  metadata {
    name = "atlantis-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"  # Built-in cluster-admin role
  }

  subject {
    kind      = "ServiceAccount"
    name      = "atlantis"
    namespace = kubernetes_namespace.atlantis.metadata[0].name
  }

  depends_on = [helm_release.atlantis]
}

# IAM Role for Atlantis via IRSA
resource "aws_iam_role" "atlantis" {
  name = "${var.project_name}-atlantis-role"
  assume_role_policy = data.aws_iam_policy_document.atlantis_assume.json
}

# Assume role policy document for Atlantis
data "aws_iam_policy_document" "atlantis_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:atlantis:atlantis"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Assign the AdministratorAccess policy to the Atlantis role
resource "aws_iam_role_policy_attachment" "atlantis_attach" {
  role       = aws_iam_role.atlantis.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Manage template for Atlantis Helm values (non-sensitive values only)
data "template_file" "atlantis_values" {
  template = file("${path.module}/../helm/atlantis.yaml")
  vars = {
    GITHUB_USER       = var.github_user
    ATLANTIS_ROLE_ARN = aws_iam_role.atlantis.arn
  }
}

# Install Atlantis using Helm
resource "helm_release" "atlantis" {
  name       = "atlantis"
  namespace  = kubernetes_namespace.atlantis.metadata[0].name
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  version    = "5.17.2"
  
  # Use YAML file for most configuration
  values = [
    data.template_file.atlantis_values.rendered
  ]

  # Override only the sensitive values
  set_sensitive {
    name  = "github.token"
    value = var.github_token
  }

  set_sensitive {
    name  = "github.secret"
    value = var.atlantis_webhook_secret
  }

  depends_on = [
    module.eks,
    kubernetes_secret.atlantis_secrets
  ]
}

# Data source to fetch the Atlantis service information
data "kubernetes_service" "atlantis" {
  metadata {
    name      = "atlantis"
    namespace = kubernetes_namespace.atlantis.metadata[0].name
  }

  depends_on = [helm_release.atlantis]
}

# Outputs
output "atlantis_role_arn" {
  value = aws_iam_role.atlantis.arn
}

output "eks_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}