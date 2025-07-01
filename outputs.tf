# (root)/outputs.tf
output "terraform_execution_role_arn" {
  value       = aws_iam_role.terraform_exec_oidc.arn
}

output "wordpress_ec2_role_arn" {
  value = aws_iam_role.wordpress_ec2_instance.arn
  description = "IAM Role ARN for WordPress EC2 instances"
}

output "wordpress_ec2_instance_profile" {
  value = aws_iam_instance_profile.wordpress_ec2_instance_profile.name
  description = "IAM Instance Profile name for EC2"
}

### Self-Hosted Runner ###
output "self_hosted_runner_role_arn" {
  value       = aws_iam_role.self_hosted_runner_exec.arn
  description = "ARN of the IAM role for the self-hosted GitHub Actions runner"
}

output "self_hosted_runner_instance_profile" {
  value       = aws_iam_instance_profile.self_hosted_runner.name
  description = "Name of the IAM instance profile for the self-hosted runner"
}
