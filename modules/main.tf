module "network" {
  source               = "./network"
  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  az_count             = var.az_count
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  default_tags         = var.default_tags
}

module "rds" {
  depends_on = [
    module.network
  ]
  source                              = "./rds"
  for_each                            = var.rds_cluster_definition
  db_indentifier                      = each.value.db_indentifier
  db_engine                           = each.value.db_engine
  db_engine_version                   = each.value.db_engine_version
  db_instance_class                   = each.value.db_instance_class
  allocated_storage                   = each.value.allocated_storage
  max_allocated_storage               = each.value.max_allocated_storage
  db_name                             = each.value.db_name
  db_username_login                   = each.value.db_username_login
  db_port                             = each.value.db_port
  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled
  multi_az                            = each.value.multi_az
  backup_retention_period             = each.value.backup_retention_period
  db_subnet_ids                       = module.network.private_subnet_ids
  db_subnet_group_id                  = module.network.rds_subnet_group_id
  db_parameter_family_group           = each.value.db_parameter_family_group
  major_engine_version                = each.value.major_engine_version
  deletion_protection                 = each.value.deletion_protection
  cross_region_replica                = each.value.cross_region_replica
  publicly_accessible                 = each.value.publicly_accessible
  apply_immediately                   = each.value.apply_immediately
  storage_encrypted                   = each.value.storage_encrypted
  storage_type                        = each.value.storage_type
  delete_automated_backups            = each.value.delete_automated_backups
  create_db_option_group              = each.value.create_db_option_group
  option_group_timeouts               = each.value.option_group_timeouts
  vpc_id                              = module.network.vpc_id
  vpc_cidr                            = var.vpc_cidr
  enable_ssm_storage_sensitive_data   = each.value.enable_ssm_storage_sensitive_data
  default_tags                        = var.default_tags

}

module "ecsfargate" {
  depends_on = [
    module.network
  ]
  source                          = "./ecs-fargate"
  for_each                        = var.ecs_fargate_cluster_definition
  ecs_cluster_name                = each.value.ecs_cluster_name
  ecs_capacity_providers          = each.value.ecs_capacity_providers
  ecs_desired_count               = each.value.ecs_desired_count
  ecs_network_mode                = each.value.ecs_network_mode
  cpu_request                     = each.value.cpu_request
  memory_request                  = each.value.memory_request
  essential                       = each.value.essential
  image_url                       = each.value.image_url
  container_port                  = each.value.container_port
  enable_application_loadbalancer = each.value.enable_application_loadbalancer
  cw_log_group                    = each.value.cw_log_group
  cw_log_stream                   = each.value.cw_log_stream
  enable_scaling                  = each.value.enable_auto_scaling
  min_capacity                    = each.value.min_capacity
  max_capacity                    = each.value.max_capacity
  vpc_id                          = module.network.vpc_id
  private_subnet_ids              = module.network.private_subnet_ids
  public_subnet_ids               = module.network.public_subnet_ids
  current_region                  = var.current_region
  default_tags                    = var.default_tags
}

module "ecr" {
  source           = "./ecr"
  for_each         = var.ecs_fargate_cluster_definition
  ecs_cluster_name = each.value.ecs_cluster_name
}

module "bastion" {
  depends_on = [
    module.network
  ]
  source                          = "./bastion"
  for_each                        = var.bastion_definition
  bastion_name                    = each.value.bastion_name
  bastion_instance_class          = each.value.bastion_instance_class
  bastion_public_key              = each.value.bastion_public_key
  user_data_base64                = each.value.user_data_base64
  bastion_ami                     = coalesce(each.value.bastion_ami, data.aws_ami.amazon-2.id)
  associate_public_ip_address     = each.value.associate_public_ip_address
  bastion_monitoring              = each.value.bastion_monitoring
  disable_api_termination         = each.value.disable_api_termination
  subnet_id                       = each.value.is_bastion_vm ? sort(module.network.public_subnet_ids)[0] : sort(module.network.private_subnet_ids)[0]
  enable_application_loadbalancer = each.value.enable_application_loadbalancer
  ingress_rules                   = each.value.ingress_rules
  egress_rules                    = each.value.egress_rules
  vpc_id                          = module.network.vpc_id
  allow_cidr_blocks               = [var.vpc_cidr]
  public_subnet_ids               = module.network.public_subnet_ids
  default_tags                    = var.default_tags
}
