# (root)/data.tf

# Retrieve current AWS account ID and region dynamically
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
