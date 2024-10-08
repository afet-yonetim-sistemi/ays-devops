provider "aws" {
  region  = var.region
  profile = var.profile
}

data "aws_availability_zones" "available" {}


# module "iam" {
#   source         = "./modules/iam"
#   profile        = var.profile
# }


module "vpc" {
  source = "./modules/vpc"
}

module "secretsmanager" {
  source = "./modules/secretsmanager"
}

module "db" {
  source             = "./modules/db"
  region             = var.region
  profile            = var.profile
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  availability_zones = data.aws_availability_zones.available.names
  master_username    = module.secretsmanager.db_username
  master_password    = module.secretsmanager.db_password
  engine_version     = var.engine_version
  security_group_ids = module.vpc.default_sg_id
}

# module "ecs" {
#   source         = "./modules/ecs"
#   region         = var.region
#   profile        = var.profile
#   vpc_id         = module.network.vpc_id
#   public_subnets = module.network.public_subnets
#   secretmanager_arn = module.secretsmanager.secret_arn
#   ecs_task_role_arn = module.iam.ecs_task_role_arn
#   ecs_service_role_arn = module.iam.ecs_service_role_arn
# }


# output "vpc_id" {
#   value = module.network.vpc_id
# }

# output "public_subnets" {
#   value = module.network.public_subnets
# }

# output "private_subnets" {
#   value = module.network.private_subnets
# }

# output "db_cluster_id" {
#   value = module.db.db_cluster_id
# }


# output "db_security_group_id" {
#   value = module.db.db_security_group_id
# }
