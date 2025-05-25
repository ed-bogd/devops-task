# eks-admin IAM user
resource "aws_iam_user" "eks_admin" {
  name = "${var.project_name}-eks-admin"
  tags = {
    Name = "eks-admin"
  }
}

# Create an IAM access key for the eks-admin user
resource "aws_iam_access_key" "eks_admin" {
  user = aws_iam_user.eks_admin.name
}

# Attach policies to the eks-admin user
resource "aws_iam_user_policy_attachment" "eks_admin_cluster" {
  user       = aws_iam_user.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "eks_admin_service" {
  user       = aws_iam_user.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_user_policy_attachment" "eks_admin_node" {
  user       = aws_iam_user.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# eks-readonly IAM role
resource "aws_iam_role" "eks_read_only" {
  name = "${var.project_name}-eks-read-only"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach policies to the eks-readonly role
resource "aws_iam_role_policy_attachment" "eks_read_only_attach" {
  role       = aws_iam_role.eks_read_only.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}