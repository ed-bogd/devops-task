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
      variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:atlantis:atlantis"]
    }
  }
}

# Assign the AdministratorAccess policy to the Atlantis role
resource "aws_iam_role_policy_attachment" "atlantis_attach" {
  role       = aws_iam_role.atlantis.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Manage template for Atlantis Helm values
data "template_file" "atlantis_values" {
  template = file("${path.module}/../helm/atlantis.yaml")

  vars = {
    ATLANTIS_GH_TOKEN       = var.github_token
    ATLANTIS_WEBHOOK_SECRET = var.atlantis_webhook_secret
    GITHUB_USER             = var.github_user
    ATLANTIS_ROLE_ARN       = aws_iam_role.atlantis.arn
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
