# This script will create a new AWS account using the AWS Control Tower Account Factory and place the new account in the "Core" OU in your organization. 
# It uses the aws_control_tower_account resource to create the new account, and the aws_organizations_organizational_unit and aws_organizations_account resources to create the OU and move the new account into it.
#
# You will need to specify the email address for the account owner and the root user, as well as the desired prefix for the account name, in the appropriate variables in the script. You will also need to configure the AWS provider with your desired region.
#
#
# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create the new AWS account using the AWS Control Tower Account Factory
resource "aws_control_tower_account" "new_account" {
  email                 = "user@example.com"
  iam_user_access_to_billing = "ALLOW"
  root_email            = "root@example.com"
  ou_id                 = "ou-0123456789abcdef"
  account_name_prefix   = "core"
}

# Wait for the new account to be created
data "aws_caller_identity" "current" {}

locals {
  account_id = aws_control_tower_account.new_account.account_id
}

data "aws_organizations_organization" "org" {
  depends_on = [aws_control_tower_account.new_account]
}

resource "aws_organizations_organizational_unit" "core" {
  parent_id            = data.aws_organizations_organization.org.roots[0].id
  name                 = "Core"
  depends_on = [aws_control_tower_account.new_account]
}

resource "aws_organizations_account" "new_account" {
  account_id           = local.account_id
  email                = "user@example.com"
  name                 = "core"
  iam_user_access_to_billing = "ALLOW"
  root_email           = "root@example.com"
  parent_id            = aws_organizations_organizational_unit.core.id
  depends_on = [aws_organizations_organizational_unit.core]
}

