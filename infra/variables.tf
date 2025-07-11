variable "auth_token" {
  description = "The secret token for API Gateway authorization"
  type        = string
  default     = "secret-token"
  sensitive   = true
}
