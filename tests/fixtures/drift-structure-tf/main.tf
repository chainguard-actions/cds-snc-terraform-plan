variable "name" {
  description = "A name variable"
  type        = string
  default     = "test"
}

output "name_output" {
  value = var.name
}
