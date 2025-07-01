# (root)/main.tf
locals {
  original_arn = data.aws_caller_identity.current.arn

  # Remove dynamic suffix from aws-go-sdk-*
  truncated_arn = replace(local.original_arn, "-${join("", slice(split("aws-go-sdk-", local.original_arn), 1, length(split("aws-go-sdk-", local.original_arn))))}", "")

  common_tags = {
    ManagedBy   = local.truncated_arn
    Environment = var.env["Environment"]
    CostCenter  = var.cost["CostCenter"]
  }
}

resource "aws_iam_role" "terraform_exec_oidc" {
  name = "terraform-execution-role-oidc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::619071346565:oidc-provider/app.terraform.io"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "app.terraform.io:aud" = "aws.workload.identity"
          },
          StringLike = {
            "app.terraform.io:sub" = "organization:my-cloud-org:project:pr-tfc-aws-wordpress:workspace:infra:run_phase:*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_policy" "terraform_exec_policy" {
  name   = "terraform-execution-role-policy"
  policy = file("${path.module}/policies/terraform-execution-role-policy.json")
  tags = local.common_tags
}

resource "aws_iam_policy_attachment" "terraform_exec_policy_attach" {
  name       = "attach-terraform-execution-policy"
  roles      = [aws_iam_role.terraform_exec_oidc.name]
  policy_arn = aws_iam_policy.terraform_exec_policy.arn
}

resource "aws_iam_role" "wordpress_ec2_instance" {
  name = "wordpress-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
  tags = local.common_tags
}

resource "aws_iam_policy" "wordpress_secret_access" {
  name = "wordpress-secrets-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "ReadWordpressSecret",
        Effect = "Allow",
        Action = "secretsmanager:GetSecretValue",
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:wordpress-secrets-*"
      },
      {
        Sid: "CloudWatchPutMetrics",
        Effect: "Allow",
        Action: [
          "cloudwatch:PutMetricData"
        ],
        Resource: "*"
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.wordpress_ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "secret_policy_attach" {
  role       = aws_iam_role.wordpress_ec2_instance.name
  policy_arn = aws_iam_policy.wordpress_secret_access.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_attach" {
  role       = aws_iam_role.wordpress_ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "wordpress_ec2_instance_profile" {
  name = "wordpress-ec2-instance-profile"
  role = aws_iam_role.wordpress_ec2_instance.name
  tags = local.common_tags
}

### Self-Hosted Runner ###

/*resource "aws_iam_role" "self_hosted_runner_exec" {
  name = "self-hosted-runner-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = local.common_tags
}*/

resource "aws_iam_role" "self_hosted_runner_exec" {
  name = "self-hosted-runner-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/app.terraform.io"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "app.terraform.io:aud" = "aws.workload.identity"
          },
          StringLike = {
            "app.terraform.io:sub" = "organization:my-cloud-org:project:*:workspace:wordpress-terraform-packer:run_phase:*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_policy" "self_hosted_runner_policy" {
  name   = "self-hosted-runner-policy"
  policy = templatefile("${path.module}/policies/self-hosted-runner-policy.tmpl.json", {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
})
tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "self_hosted_runner_policy_attach" {
  role       = aws_iam_role.self_hosted_runner_exec.name
  policy_arn = aws_iam_policy.self_hosted_runner_policy.arn
}

resource "aws_iam_instance_profile" "self_hosted_runner" {
  name = "self-hosted-runner-instance-profile"
  role = aws_iam_role.self_hosted_runner_exec.name
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "runner_ssm_core_attach" {
  role       = aws_iam_role.self_hosted_runner_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}