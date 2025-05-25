###
# eks-admin IAM user and role
###

# eks-admin IAM user
resource "aws_iam_user" "eks_admin" {
  name = "eks-admin-user"
  tags = {
    Name = "eks-admin"
  }
}

# Create an IAM access key for the eks-admin user
resource "aws_iam_access_key" "eks_admin" {
  user = aws_iam_user.eks_admin.name
}

# eks-admin IAM role
resource "aws_iam_role" "eks_admin" {
  name = "eks-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "eks-admin"
  }
}

# Allow the user to assume the role
resource "aws_iam_user_policy" "eks_admin_assume_role" {
  name = "eks-admin-assume-role"
  user = aws_iam_user.eks_admin.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = aws_iam_role.eks_admin.arn
      }
    ]
  })
}

# Add a custom policy for EKS describe operations
resource "aws_iam_policy" "eks_admin_policy" {
  name = "eks-admin-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:*",
          "autoscaling:*",
          "cloudformation:*",
          "iam:*",
          "logs:*",
          "elasticloadbalancing:*",
          "elasticfilesystem:*",
          "route53:*",
          "acm:*",
          "secretsmanager:*",
          "ssm:*",
          "cloudwatch:*",
          "ecr:*",
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the admin policy to the eks-admin role
resource "aws_iam_role_policy_attachment" "eks_admin_role_policy" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin_policy.arn
}

###
# eks-readonly IAM user
###

# eks-readonly IAM user
# resource "aws_iam_user" "eks_read_only" {
#   name = "eks-read-only-user"
#   tags = {
#     Name = "eks-read-only"
#   }
# }

# # Create an IAM access key for the eks-read-only user
# resource "aws_iam_access_key" "eks_read_only" {
#   user = aws_iam_user.eks_read_only.name
# }

# # eks-readonly IAM role
# resource "aws_iam_role" "eks_read_only" {
#   name = "eks-read-only"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })

#   tags = {
#     Name = "eks-read-only"
#   }
# }

# # Allow the read-only user to assume the read-only role
# resource "aws_iam_user_policy" "eks_read_only_assume_role" {
#   name = "eks-read-only-assume-role"
#   user = aws_iam_user.eks_read_only.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "sts:AssumeRole"
#         Resource = aws_iam_role.eks_read_only.arn
#       }
#     ]
#   })
# }

# # Custom read-only policy for EKS using wildcards
# resource "aws_iam_policy" "eks_read_only_policy" {
#   name        = "eks-read-only-policy"
#   description = "Read-only access to EKS cluster using wildcards"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "eks:Describe*",
#           "eks:List*",
#           "ec2:Describe*",
#           "autoscaling:Describe*",
#           "cloudformation:Describe*",
#           "cloudformation:List*",
#           "iam:List*",
#           "iam:Get*",
#           "logs:Describe*",
#           "logs:Get*",
#           "logs:Filter*",
#           "elasticloadbalancing:Describe*",
#           "elasticfilesystem:Describe*",
#           "route53:List*",
#           "route53:Get*",
#           "acm:List*",
#           "acm:Describe*",
#           "secretsmanager:Describe*",
#           "secretsmanager:List*",
#           "ssm:Describe*",
#           "cloudwatch:Get*",
#           "cloudwatch:List*",
#           "cloudwatch:Describe*",
#           "ecr:Describe*",
#           "ecr:List*",
#           "ecr:Get*",
#           "kms:Describe*",
#           "kms:List*"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach the custom read-only policy to the eks-readonly role
# resource "aws_iam_role_policy_attachment" "eks_read_only_custom" {
#   role       = aws_iam_role.eks_read_only.name
#   policy_arn = aws_iam_policy.eks_read_only_policy.arn
# }
