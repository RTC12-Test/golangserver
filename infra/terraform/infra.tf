# Fetching properties of ecs cluster.
data "aws_ecs_cluster" "get_ecs_cluster" {
  cluster_name = lookup(local.configs, "aws_ecs_cluster_name")
}

# Module for configuring common settings
module "config" {
  source                = "git::git@github.com:RTC12-Test/my-sso-infra.git//infra/terraform/modules/config?ref=feature/secrets"
  enable_config_secrets = true
  app_name              = lookup(local.configs, "app_name")
  org_name              = lookup(local.configs, "org_name")
  division              = lookup(local.configs, "division")
  department            = lookup(local.configs, "department")
  technicalContact      = lookup(local.configs, "technicalContact")
}

# Calling locals of config module
locals {
  configs      = nonsensitive(module.config.config_env)
  default_tags = module.config.default_tags
  secrets      = module.config.secrets
}

# Calling ECR module to create ECR Repository
module "ecr" {
  source           = "git::git@github.com:RTC12-Test/my-sso-infra.git//infra/terraform/modules/ecr?ref=feature/secrets"
  app_name         = lookup(local.configs, "app_name")
  org_name         = lookup(local.configs, "org_name")
  env              = terraform.workspace
  service_name     = lookup(local.configs, "service_name")
  default_tags     = local.default_tags
  map_migrated_tag = lookup(local.configs, "map_migrated_tag")
}

# Calling the security-group module to create the security groups for ECS and NLB
module "security_group" {
  source               = "git::git@github.com:RTC12-Test/my-sso-infra.git//infra/terraform/modules/security-group?ref=feature/secrets"
  aws_sg_configuration = lookup(local.configs, "aws_sg_configuration")
  app_name             = lookup(local.configs, "app_name")
  org_name             = lookup(local.configs, "org_name")
  env                  = terraform.workspace
  service_name         = lookup(local.configs, "service_name")
  default_tags         = local.default_tags
  aws_vpc_id           = lookup(local.configs, "aws_vpc_id")
  map_migrated_tag     = lookup(local.configs, "map_migrated_tag")
}

# # Calling Task-Defintion Module to create Task Definition
# module "task-definition" {
#   source                         = "git::git@github.com:RTC12-Test/my-sso-infra.git//infra/terraform/modules/task-definition?ref=feature/secrets"
#   app_name                       = lookup(local.configs, "app_name")
#   org_name                       = lookup(local.configs, "org_name")
#   env                            = terraform.workspace
#   aws_region                     = lookup(local.configs, "region")
#   service_name                   = lookup(local.configs, "service_name")
#   default_tags                   = local.default_tags
#   aws_task_execution_role        = lookup(local.configs, "aws_task_execution_role")
#   task_definition_file           = module.config.taskdefintionfile
#   aws_ecs_task_definition_memory = local.configs.task_definition_variables.aws_ecs_task_definition_memory
#   aws_ecs_task_definition_cpu    = local.configs.task_definition_variables.aws_ecs_task_definition_cpu
#   map_migrated_tag               = lookup(local.configs, "map_migrated_tag")
#
#   task_definition_variables = {
#     containers = [
#       {
#         name         = local.configs.task_definition_variables.containers[0].name
#         portMappings = local.configs.task_definition_variables.containers[0].portMappings
#         essential    = local.configs.task_definition_variables.containers[0].essential
#         image        = "${local.configs.task_definition_variables.aws_ecr_repo_url}:${lookup(local.configs.task_definition_variables, "docker_image_tag")}"
#         entryPoint   = local.configs.task_definition_variables.containers[0].entryPoint
#         mountPoints  = local.configs.task_definition_variables.containers[0].mountPoints
#         secrets = {
#           "secret"     = "${local.configs.task_definition_variables.aws_secret_manager_arn}secrets::"
#         }
#         environment = {
#           "test"          = local.configs.task_definition_variables.testkey
#         }
#         linuxParameters = {
#           capabilities = {
#             add = [
#               "SYS_PTRACE"
#             ]
#           }
#         }
#       }
#     ],
#     volumes = try(local.configs.task_definition_variables.volumes, [])
#   }
# }
#
# # Calling ECS Service Module to create the ECS service
# module "ecs-svc" {
#   source                             = "git::git@github.com:RTC12-Test/my-sso-infra.git//infra/terraform/modules/ecs-service?ref=feature/secrets"
#   app_name                           = lookup(local.configs, "app_name")
#   org_name                           = lookup(local.configs, "org_name")
#   env                                = terraform.workspace
#   service_name                       = "${lookup(local.configs, "service_name")}-svc"
#   default_tags                       = local.default_tags
#   aws_ecs_service_vpc_subnet         = lookup(local.configs, "aws_subnet")
#   aws_ecs_service_task_arn           = module.task-definition.task_arn
#   aws_ecs_cluster_id                 = data.aws_ecs_cluster.get_ecs_cluster.id
#   aws_ecs_service_container_name     = local.configs.task_definition_variables.containers[0].name
#   aws_ecs_service_container_port     = local.configs.task_definition_variables.containers[0].portMappings[0].containerPort
#   aws_ecs_service_sg_id              = [module.security_group.aws_sg_id["app-ecs"], local.configs.aws_sg_ids[0]]
#   aws_ecs_cluster_name               = data.aws_ecs_cluster.get_ecs_cluster.cluster_name
#   aws_lb_green_target_group_name     = module.target-groups["accountsvcgreen"].tg_name
#   aws_lb_blue_target_group_name      = module.target-groups["accountsvcblue"].tg_name
#   aws_nlb_listener                   = lookup(local.configs, "aws_lb_listener_arn")
#   aws_lb_active_target_group_arn     = module.target-groups["accountsvcblue"].tg_arn
#   sso_infra_deploy_arn               = lookup(local.configs, "sso_infra_deploy_arn")
#   aws_ecs_service_task_desired_count = lookup(local.configs, "aws_ecs_service_task_desired_count")
#   enable_execute_command             = lookup(local.configs, "aws_ecs_service_enable_execute_command")
# }
