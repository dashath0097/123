terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"  # Ensure latest compatible version
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

# Define known stack names (replace with actual names)
locals {
  stack_names = ["aditya_2", "demo2"]  # Add all stack names here
}

# Fetch stack details for each stack name
data "spacelift_stack" "all_stacks" {
  for_each = toset(local.stack_names)
  name     = each.value
}

# Attach the policy to all stacks by stack name
resource "spacelift_policy_attachment" "iam_policy_attachment" {
  for_each  = data.spacelift_stack.all_stacks
  policy_id = spacelift_policy.iam_policy.id
  stack_id  = each.value.id
}
