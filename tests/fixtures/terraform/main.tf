# Minimal Terraform configuration for testing
terraform {
  required_version = ">= 1.0"
}

output "hello" {
  value = "world"
}
