# Create a Kubernetes namespace for Atlantis
resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = "atlantis"
  }
}

# IAM Role for Atlantis via IRSA
resource "aws_iam_role" "atlantis" {
  name = "${var.project_name}-atlantis-role"

  assume_role_policy = data.aws_iam_policy_document.atlantis_assume.json
}

# Grant cluster-admin to Atlantis service account
resource "kubernetes_cluster_role_binding" "atlantis_cluster_admin" {
  metadata {
    name = "atlantis-cluster-admin"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = "atlantis"
    namespace = kubernetes_namespace.atlantis.metadata[0].name
  }

  depends_on = [module.eks]
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

# Add output to verify the role ARN
output "atlantis_role_arn" {
  value = aws_iam_role.atlantis.arn
}

# Add output to verify OIDC issuer
output "eks_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

# Update the template data to use conditional reference
data "template_file" "atlantis_values" {
  template = file("${path.module}/../helm/atlantis.yaml")

  vars = {
    GITHUB_USER       = var.github_user
    ATLANTIS_ROLE_ARN = aws_iam_role.atlantis.arn
    GITHUB_TOKEN    = var.github_token
    GITHUB_REPO      = var.github_repo
    ATLANTIS_WEBHOOK_SECRET = var.atlantis_webhook_secret
  }
}

# Install Atlantis using Helm
resource "helm_release" "atlantis" {
  name       = "atlantis"
  namespace  = kubernetes_namespace.atlantis.metadata[0].name
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  version    = "5.17.2"

  values = [
    data.template_file.atlantis_values.rendered
  ]

  depends_on = [module.eks]
}

# Data source to fetch the Atlantis service
data "kubernetes_service" "atlantis" {
  metadata {
    name      = "atlantis"
    namespace = "atlantis"
  }

  depends_on = [helm_release.atlantis]
}