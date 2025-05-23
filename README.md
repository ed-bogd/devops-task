# devops-task

### Task description

1. Create your AWS account.
2. Deploy EKS and Atlantis application ([https://www.runatlantis.io](https://www.runatlantis.io)) using Terraform and Helm.
3. Configure the application to use your GitHub project repository.
4. Create a pull request against your repository, to prove Atlantis is working.

---

### Functional requirements:

1. 1 VPC, 2 subnets, 1 EKS cluster.
2. Worker autoscaling group with min 1, max 2 workers.
3. K8s role-based access is configured with two IAM roles – `eks-admin` (with admin access) and `eks-read-only` (for read-only access).

---

### Non-functional requirements:

1. All infrastructure is deployed as code.
2. Deployment doesn't require manual steps.
3. Code is pushed to GitHub, and shared for assessment.

---
