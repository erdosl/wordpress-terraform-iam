# WordPress Terraform IAM

This repository provisions IAM roles and policies required to securely deploy WordPress infrastructure and perform Terraform operations in AWS.

## Project Structure and Execution Order

This project is part of a 3-repository infrastructure setup:

1. [`erdosl/wordpress-terraform-iam`](https://github.com/erdosl/wordpress-terraform-iam)  
   Provisions the IAM roles and policies required to securely run Terraform and EC2 instances.

2. [`erdosl/wordpress-terraform`](https://github.com/erdosl/wordpress-terraform)  
   Deploys the AWS infrastructure then tries to use the AMI - which does not exists yet. So, proceed to step 3. to bake one.
   
3. [`erdosl/wordpress-terraform-packer`](https://github.com/erdosl/wordpress-terraform-packer)  
   Builds a custom AMI containing WordPress, Apache, PHP, and required agents.

> ⚠️ At initial setup, the `wordpress-terraform` deployment will **fail** when trying to find a baked AMI - which is expected - since at that stage there is no baked AMI, yet.
> ⚠️ At the same time, the `packer` project relies on outputs (like EFS ID and subnets) from the `wordpress-terraform` infrastructure to mount persistent storage and configure networking, which means you cannot run the wordpress-terraform-packer without wordpress-terraform.

Make sure to run the repositories in the correct order and run the AMI build after the infrastructure is ready. Currently, the AMI build is manually run.

## Overview

This module creates a Terraform execution IAM role with a unified policy allowing access to resources like EC2, ALB, EFS, IAM, and more.


# Terraform IAM Module for AWS Infrastructure Automation

This module provisions a secure and reusable IAM role and policy for Terraform-based deployments on AWS. It enables automated infrastructure provisioning via Terraform Cloud or GitHub Actions workflows with appropriate permissions following best practices.

---

## Table of Contents

- [Project Context](#project-context)  
- [Overview](#overview)  
- [Architecture](#architecture)  
- [Usage](#usage)  
- [Requirements](#requirements)  
- [Outputs](#outputs)  
- [Terraform Cloud Integration](#terraform-cloud-integration)  
- [Related Projects](#related-projects)  
- [Contact](#contact)

---

## Project Context

This module is part of a broader Infrastructure-as-Code system that automates the deployment of a full WordPress stack on AWS using:

- Terraform for infrastructure provisioning  
- Packer for AMI creation  
- GitHub Actions (self-hosted runners) for CI/CD automation  
- Terraform Cloud for state management and workflow execution

This IAM module enables Terraform to perform deployments securely by provisioning roles with scoped access to AWS services.

---

## Overview

This module provisions the following:

- An IAM Role: `terraform-execution-role-oidc`  
- An IAM Policy: `terraform-execution-role-policy`  
- A role trust policy (configurable for either EC2 or OIDC-based identity providers)  
- IAM policy attachment for centralized control  

The IAM policy grants permissions across commonly used AWS services to support provisioning of production-ready infrastructure, including:

- EC2 (instances, VPC, subnets, security groups)  
- EFS (file systems and mount targets)  
- RDS (database services)  
- ELB (load balancers and listeners)  
- Auto Scaling  
- Secrets Manager  
- IAM (limited to `iam:PassRole`)  
- CloudWatch Logs and Alarms

---

## Architecture

This IAM module is intended to support CI/CD systems where Terraform assumes a temporary role to provision infrastructure. It is compatible with:

- Terraform Cloud (via OIDC federation)  
- EC2-based runners (via instance profile)  
- Secure API token integration via Terraform Cloud or GitHub Actions secrets  

Role trust and access scope can be configured to match your cloud environment and organizational policies.

---

## Usage

1. Clone the module or add it to your Terraform configuration:

    ```hcl
    module "iam_execution_role" {
      source = "github.com/your-org/terraform-aws-iam-terraform-role"
    }
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Plan and apply the configuration:

    ```bash
    terraform plan
    terraform apply
    ```

After successful apply, a role will be created in your AWS account and ready to be assumed by your Terraform automation platform.

---

## Requirements

- Terraform version 1.12.0 or higher  
- AWS Provider version ~> 5.98  
- AWS Account with admin privileges to create IAM resources  
- If using Terraform Cloud: appropriate OIDC trust and workspace setup

Note: The AWS Account ID in `main.tf` is a placeholder and should be replaced with your actual account.

---

## Outputs

| Output      | Description                                  |
|-------------|----------------------------------------------|
| `role_arn`  | ARN of the created execution role            |

Example:
arn:aws:iam::123456789012:role/terraform-execution-role


---

## Terraform Cloud Integration

This module is configured to work with Terraform Cloud for remote execution and state storage.

Ensure your workspace in Terraform Cloud is configured with:

- A valid organization and workspace name  
- Environment variables such as `TF_VAR_aws_region`  
- A trust relationship for OIDC (if using web identity federation)  

If using EC2-based runners or local execution, ensure that credentials are securely configured using IAM instance profiles or access keys.

---

## Related Projects

- `wordpress-terraform`: WordPress infrastructure on AWS using Terraform modules  
- `wordpress-packer`: Custom AMI builder using Packer  
- `github-actions-runner-module`: Self-hosted runner deployment for GitHub Actions  

---

## Contact

If you are reviewing this as part of a skills evaluation or portfolio review, feel free to reach out for a walkthrough or additional context.

**erdosl**
GitHub: [github.com/erdosl](https://github.com/erdosl)  

