
provider "harness" {
  alias            = "provisioner"
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.harness_platform_account_id
  platform_api_key = var.harness_platform_api_key
}

terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }

  backend "artifactory" {}
}
