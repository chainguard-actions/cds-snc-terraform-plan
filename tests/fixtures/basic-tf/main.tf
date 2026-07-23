variable "example" {
  description = "An example variable"
  type        = string
  default     = "hello"
}

output "example_output" {
  value = var.example
}
