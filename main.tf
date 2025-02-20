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
provider "spacelift" {}

# Fetch all stacks
data "spacelift_stacks" "all_stacks" {}

# Define the policy
resource "spacelift_policy" "iam_policy_approval" {
  name = "require_security_approval_for_iam_policy"
  type = "PLAN"
  body = file("iam_policy_approval.rego")
}

# Attach policy to all stacks
resource "spacelift_policy_attachment" "iam_policy_attachment" {
  for_each  = { for stack in data.spacelift_stacks.all_stacks.stacks : stack.context => stack.context }

  stack_id  = each.value
  policy_id = spacelift_policy.iam_policy_approval.id
}
