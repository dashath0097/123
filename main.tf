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
# Fetch all stacks dynamically
data "spacelift_stacks" "all_stacks" {}

# Define the policy
resource "spacelift_policy" "iam_policy_approval" {
  name       = "require_security_approval_for_iam_policy"
  type       = "PLAN"
  body       = file("iam_policy_approval.rego")
}

# Attach policy to all stacks
resource "spacelift_stack_policy_attachment" "iam_policy_attachment" {
  for_each  = toset(data.spacelift_stacks.all_stacks.ids)

  stack_id  = each.key
  policy_id = spacelift_policy.iam_policy_approval.id
}
