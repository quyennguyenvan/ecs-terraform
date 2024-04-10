
module "ezservices" {

  source = "./modules"

  #Network
  vpc_name             = "ez-services-dev"
  vpc_cidr             = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  az_count             = var.az_count

  #ECS
  ecs_fargate_cluster_definition = var.ecs_cluster_definition
  #RDS
  rds_cluster_definition = var.rds_cluster_definition
  #bastion
  bastion_definition = var.bastion_definition
  #COMMON variable
  current_region = data.aws_region.current_region.name

  #COMMON Tags
  default_tags = var.default_tags

}
