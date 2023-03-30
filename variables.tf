variable "python_version" {
  description = "Python version for lambda function"
  type        = string
  default     = "python3.8"
}

variable "stage" {
  description = "Deployment environment"
  type        = string
  default     = "test"
}
