
variable "log_level" {
  type = string
  default = "INFO"
  description = "Log level of service application."
}

variable "stage" {
  type = string
}

variable "auth_domain" {
  type = string
}

variable "auth_audience" {
  type = string
}

variable "autoscaling_group_arn" {
  type = string
}

variable "autoscaling_group_name" {
  type = string
}

variable "server_domain" {
  type = string
}

data "aws_region" "current" {}

resource "random_id" "stack_name" {
  keepers = {
    stage = var.stage
    region = data.aws_region.current.name
  }

  byte_length = 8
}

locals {
  stack_name = "service-${var.stage}-${random_id.stack_name.hex}"
  dynamodb_by_user_index = "ByUserIndex"
}

module "files-changed" {
  source = "../_modules/files-change"
  root = path.module
  files = flatten([
    fileset(path.module, "*.py"),
    [
      "serverless.yml",
      "pyproject.toml",
      "poetry.lock",
      "package.json",
      "package-lock.json",
    ]
  ])
}

resource "null_resource" "serverless_app" {
  triggers = {
    files-changed = module.files-changed.trigger
  }

  provisioner "local-exec" {
    command = "serverless deploy"
    working_dir = path.module
    environment = {
      STAGE = var.stage
      AWS_REGION = data.aws_region.current.name
      LOG_LEVEL = var.log_level
      AUTH_DOMAIN = var.auth_domain
      AUTH_AUDIENCE = var.auth_audience
      AUTOSCALING_GROUP_NAME = var.autoscaling_group_name
      AUTOSCALING_GROUP_ARN = var.autoscaling_group_arn
      SERVICE_STACK_NAME = local.stack_name
      SERVER_DOMAIN = var.server_domain
      DYNAMODB_BY_USER_INDEX = local.dynamodb_by_user_index
      DYNAMODB_SERVICE_TABLE_ID = aws_dynamodb_table.service_table.id
      DYNAMODB_SERVICE_TABLE_ARN = aws_dynamodb_table.service_table.arn
    }
  }
}

resource "random_id" "by_id_table_name" {
  prefix      = "ByIdTable"
  byte_length = 8
}

resource "aws_dynamodb_table" "service_table" {
  name           = random_id.by_id_table_name.b64_url
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  attribute {
    name = "User"
    type = "S"
  }

  global_secondary_index {
    name           = local.dynamodb_by_user_index
    hash_key       = "User"
    range_key      = "Id"
    projection_type    = "ALL"
  }
}

output "dynamodb_service_table_name" {
  value = random_id.by_id_table_name.b64_url
}

output "stack_name" {
  value = local.stack_name
}
