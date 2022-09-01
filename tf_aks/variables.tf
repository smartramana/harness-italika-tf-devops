variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

# variable "harness_platform_api_key" {
#   sensitive = true
# }
# variable "harness_platform_account_id" {
#   sensitive = true
# }
variable "access_key" {
  sensitive = true
}
variable "secret_key" {
  sensitive = true
}
