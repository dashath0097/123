terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"  # Use the latest version
    }
  }
}

provider "spacelift" {
  # Spacelift API credentials (configure via environment variables)
}

# Define the IAM policy
resource "spacelift_policy" "iam_policy" {
  name        = "IAM Policy"
  description = "Global IAM policy for all stacks"
  body        = file("${path.module}/iam_policy.rego")  # Ensure this file exists
  type        = "ACCESS"
}

# Retrieve all Spacelift stacks
data "spacelift_stacks" "all_stacks" {}

# Attach the policy to all stacks
resource "spacelift_policy_attachment" "iam_policy_attachment" {
  for_each   = { for stack in data.spacelift_stacks.all_stacks.stacks : stack.id => stack.id }
  policy_id  = spacelift_policy.iam_policy.id
  stack_id   = each.value
}



