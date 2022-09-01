module "bootstrap_italika_org" {
  source                    = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  harness_platform_projects = local.harness_platform_projects

  providers = {
    harness = harness.provisioner
  }
}

module "bootstrap_italika_delegates" {
  depends_on = [
    module.bootstrap_italika_org,
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"
  harness_platform_delegates = local.harness_platform_delegates
  harness_platform_api_key   = var.harness_platform_api_key
}

module "bootstrap_italika_connectors" {
  depends_on = [
    module.bootstrap_italika_org,
    module.bootstrap_italika_delegates
  ]
  source                      = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connectors?ref=main"
  harness_platform_connectors = local.harness_platform_connectors

  providers = {
    harness = harness.provisioner
  }
}

# resource "local_file" "template" {
#   content = templatefile("../contrib/harness/templates/terraform-pipeline.tpl", {
#     org_identifier     = module.bootstrap_harness.organization[var.cristian_lab_org_projects.organization_name].org_id
#     git_connector_ref  = "org.italika_platform-dev_github_connector"
#     secret_manager_ref = "org.harnessSecretManager"
#     approver_ref       = "account.SE_Admin"
#     delegate_ref       = "italika_lab-gke-tf"
#     tf_backend = {
#       username = "admin"
#       password = "<+secrets.getValue(\"harness_connectors_crizstian_artifactory_token\")>"
#       url      = "http://artifactory--se-latam-demo.harness-demo.site.harness-demo.site.harness-demo.site/artifactory"
#       repo     = "Terraform-Backend"
#       subpath  = "harness-bootstrap"
#     }
#     tf_variables = {
#       harness_platform_api_key                       = "<+secrets.getValue(\"harness_platform_api_key\")>"
#       harness_platform_account_id                    = "<+secrets.getValue(\"harness_platform_account_id\")>"
#       harness_connectors_crizstian_github_token      = "<+secrets.getValue(\"harness_connectors_crizstian_github_token\")>"
#       harness_connectors_crizstian_docker_token      = "<+secrets.getValue(\"harness_connectors_crizstian_docker_token\")>"
#       harness_connectors_crizstian_artifactory_token = "<+secrets.getValue(\"harness_connectors_crizstian_artifactory_token\")>"
#     }
#   })
#   filename = "${path.module}/terraform-pipeline.yml"
# }

# resource "null_resource" "upload_templates" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     working_dir = path.root
#     command     = <<-EOT
#         echo "curl  -i -X POST ${var.harness_template_endpoint}${local.harness_template_endpoint_account_args} --header Content-Type: application/yaml --header x-api-key: ${var.harness_platform_api_key} -d '${local_file.template.content}'"
#         curl  -i -X POST '${var.harness_template_endpoint}${local.harness_template_endpoint_account_args}' \
#         --header 'Content-Type: application/yaml' \
#         --header 'x-api-key: ${var.harness_platform_api_key}' -d '
#         ${local_file.template.content}
#         '
#         EOT
#   }
# }

data "local_file" "template" {
  depends_on = [
    module.bootstrap_italika_org,
  ]
  filename = "../contrib/harness/templates/terraform.yml"
}

resource "null_resource" "template" {
  depends_on = [
    module.bootstrap_italika_org,
  ]
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
        curl  -i -X POST '${var.harness_template_endpoint}${local.harness_template_endpoint_account_args}' \
        --header 'Content-Type: application/yaml' \
        --header 'x-api-key: ${var.harness_platform_api_key}' -d '
        ${data.local_file.template.content}
        '
        EOT
  }
}

output "details" {
  value = {
    organization = module.bootstrap_italika_org.organization
    delegates    = module.bootstrap_italika_delegates.delegates
    project      = module.bootstrap_italika_org.project
  }
}
