resource "aws_key_pair" "bastion_keypair" {
  key_name   = var.bastion_name
  public_key = var.bastion_public_key
  tags       = var.default_tags
}
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.3.0"

  name                        = var.bastion_name
  associate_public_ip_address = var.associate_public_ip_address
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_class
  key_name                    = aws_key_pair.bastion_keypair.key_name
  monitoring                  = var.bastion_monitoring
  vpc_security_group_ids      = [aws_security_group.this.id]
  subnet_id                   = var.subnet_id
  disable_api_termination     = var.disable_api_termination
  user_data_base64            = var.user_data_base64

  volume_tags = var.default_tags
  tags        = merge({ Name = var.bastion_name }, var.default_tags)
}

#=============================================
# OUTPUT
#=============================================

output "bastion_key_pair_name" {
  value = aws_key_pair.bastion_keypair.key_name
}

output "bastion_public_ip" {
  value = module.ec2_instance.public_ip
}
