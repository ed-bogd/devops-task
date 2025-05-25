variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "dzenrei"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Prefix for resources"
  type        = string
  default     = "atlantis-demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr2" {
  description = "CIDR block for second public subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr2" {
  description = "CIDR block for second private subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "demo-cluster"
}

variable "desired_capacity" {
  description = "Desired node count"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum node count"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum node count"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "github_repo" {
  description = "GitHub repo in format owner/repo"
  type        = string
  default     = "ed-bogd/devops-task"
}

variable "github_user" {
  description = "GitHub username or organization"
  type        = string
  default     = "ed-bogd"
}

variable "atlantis_repo_whitelist" {
  description = "Atlantis repo allowlist"
  type        = list(string)
  default     = ["github.com/ed-bogd/devops-task"]
}

variable "atlantis_webhook_secret" {
  description = "GitHub webhook secret for Atlantis"
  type        = string
  sensitive   = true
  default = ""
}

variable "github_token" {
  description = "GitHub token for Atlantis"
  type        = string
  sensitive   = true
  default = ""
}

variable "my_ip_address" {
  description = "Your public IP address for security group rules"
  type        = string
  sensitive   = true
  default = ""
}