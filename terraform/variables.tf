variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "access_key" {
  description = "The AWS access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "The AWS secret key"
  type        = string
  sensitive   = true
}
