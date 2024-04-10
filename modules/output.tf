output "vpc_id" {
  value = module.network.vpc_id
}
output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "db_instance_address" {
  value = { for k, v in module.rds : k => v.db_instance_address }
}
output "db_instance_arn" {
  value = { for k, v in module.rds : k => v.db_instance_arn }
}
output "db_instance_name" {
  value = { for k, v in module.rds : k => v.db_instance_name }
}

output "db_instance_username" {
  value = { for k, v in module.rds : k => v.db_instance_username }
}

output "db_instance_password" {
  value = { for k, v in module.rds : k => v.db_instance_password }
}

output "alb_address" {
  value = { for k, v in module.ecsfargate : k => v.alb_address }
}

output "ecr_repository_arn" {
  value = { for k, v in module.ecr : k => v.ecr_repository_arn }
}
output "bastion_key_pair_name" {
  value = { for k, v in module.bastion : k => v.bastion_key_pair_name }
}
output "bastion_public_ip" {
  value = { for k, v in module.bastion : k => v.bastion_public_ip }
}

output "ec2_alb_address" {
  value = { for k, v in module.bastion : k => v.ec2_alb_address }

}
