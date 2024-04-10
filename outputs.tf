output "account-id" {
  value = data.aws_caller_identity.current.account_id
}
output "current_region" {
  value = data.aws_region.current_region.name
}
output "vpc_id" {
  value = module.ezservices.vpc_id
}
output "private_subnet_ids" {
  value = module.ezservices.private_subnet_ids
}
output "public_subnet_ids" {
  value = module.ezservices.public_subnet_ids
}
output "db_instance_address" {
  value = module.ezservices.db_instance_address
}
output "db_instance_arn" {
  value = module.ezservices.db_instance_arn
}
output "db_instance_name" {
  value = module.ezservices.db_instance_name
}
output "db_instance_username" {
  value     = module.ezservices.db_instance_username
  sensitive = true
}
output "db_instance_password" {
  value     = module.ezservices.db_instance_password
  sensitive = true
}
output "alb_address" {
  value = module.ezservices.alb_address
}
output "ecr_repository_arn" {
  value = module.ezservices.ecr_repository_arn
}
output "bastion_key_pair_name" {
  value = module.ezservices.bastion_key_pair_name
}
output "bastion_public_ip" {
  value = module.ezservices.bastion_public_ip
}
output "ec2_alb_address" {
  value = module.ezservices.ec2_alb_address
}
output "ssm_infor" {
  value = "Please check SSM to retrive sensitive data of database instance"
}
