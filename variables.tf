# (root)/variables.tf

variable "aws_region" {
  type    = string
  # default = "eu-west-2"
}

variable "env" {
  type        = map(string)
  description = "Environment"
  default = {
    "Environment" = "dev-wordpress"
  }
}

variable "cost" {
  type        = map(string)
  description = "Cost Center Number"
  default = {
    "CostCenter" = "IAM is free"
  }
}