
variable "domain_name" {}
variable "access_key" {}
variable "minecraft_bucket" {}
variable "stage" {}
variable "auth_audience" {}
variable "auth_domain" {}
variable "certificate_arn" {}


data "aws_route53_zone" "hosted_zone" {
  name         = "${var.domain_name}."
}

module "mcserver" {

  source = "./mcserver"

  access_key  = var.access_key
  domain_name = "mc.${var.domain_name}"
  hostedzone_id = data.aws_route53_zone.hosted_zone.zone_id
  minecraft_bucket = var.minecraft_bucket
}

module "portal" {
  source = "./portal"
}

module "service" {
  source = "./service"

  stage = var.stage
  autoscaling_group_name = module.mcserver.mc_autoscaling_group_name
  autoscaling_group_arn = module.mcserver.mc_autoscaling_group_arn
  auth_audience = var.auth_audience
  auth_domain = var.auth_domain
}

module "cdn" {
  source = "./cdn"

  certificate_arn = var.certificate_arn
  service_stack_name = module.service.stack_name
  service_path = "/${var.stage}"
  domain_name = var.domain_name
  hosted_zone_id = data.aws_route53_zone.hosted_zone.zone_id
  portal_domain = module.portal.domain
  portal_access_identity = module.portal.access_identity
}

output "autoscaling_group_name" {
  value = module.mcserver.mc_autoscaling_group_name
}
