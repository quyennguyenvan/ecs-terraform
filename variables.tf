variable "default_tags" {
  default = {
    "Created By"       = "QuyenNV9",
    "Impact"           = "High",
    "Project"          = "EZ-Services",
    "Env"              = "Prod",
    "Last Modified By" = "QuyenNV9"
    "Maintenance By"   = "Terraform"
  }
  description = "Additional resource tags"
  type        = map(string)
}
variable "vpc_cidr" {
  default     = "10.10.0.0/16"
  type        = string
  description = "The VPC Subnet CIDR"
}

#ecs varible
variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "3"
}
variable "ecs_cluster_definition" {
  description = "The definition of ECS"
  type = map(object({
    ecs_cluster_name                = string
    ecs_capacity_providers          = string
    ecs_desired_count               = number
    ecs_network_mode                = string
    cpu_request                     = number
    memory_request                  = number
    essential                       = bool
    image_url                       = string
    container_port                  = number
    enable_application_loadbalancer = bool
    cw_log_group                    = string
    cw_log_stream                   = string
    enable_auto_scaling             = bool
    min_capacity                    = number
    max_capacity                    = number
    docker_volume = object({
      name = string
      docker_volume_configuration = object({
        scope         = string
        autoprovision = bool
        driver        = string
        labels        = map(string)
      })
    })
    mount_points = map(string)
  }))
  default = {
    "app" = {
      ecs_cluster_name                = "ez-app-fargate-cluster"
      ecs_capacity_providers          = "FARGATE"
      container_port                  = 8080
      cpu_request                     = 256
      memory_request                  = 512
      cw_log_group                    = "ez-services-app"
      cw_log_stream                   = "ez-services-app-fargate"
      ecs_desired_count               = 1
      ecs_network_mode                = "awsvpc"
      enable_application_loadbalancer = true
      essential                       = true
      image_url                       = "729713917879.dkr.ecr.us-west-2.amazonaws.com/ez-app-fargate-cluster:1"
      enable_auto_scaling             = true
      min_capacity                    = 1
      max_capacity                    = 9
      docker_volume                   = null
      mount_points                    = null
    },
    "job" = {
      ecs_cluster_name                = "ez-job-fargate-cluster"
      ecs_capacity_providers          = "FARGATE"
      container_port                  = 8088
      cpu_request                     = 256
      memory_request                  = 512
      cw_log_group                    = "ez-services-job"
      cw_log_stream                   = "ez-services-job-fargate"
      ecs_desired_count               = 1
      ecs_network_mode                = "awsvpc"
      enable_application_loadbalancer = false
      essential                       = true
      image_url                       = "729713917879.dkr.ecr.us-west-2.amazonaws.com/ez-job-fargate-cluster:1"
      enable_auto_scaling             = true
      min_capacity                    = 1
      max_capacity                    = 9
      docker_volume                   = null
      mount_points                    = null
    },
    "mail" = {
      ecs_cluster_name                = "ez-mail-fargate-cluster"
      ecs_capacity_providers          = "FARGATE"
      container_port                  = 587
      cpu_request                     = 256
      memory_request                  = 512
      cw_log_group                    = "ez-services-mail"
      cw_log_stream                   = "ez-services-mail-fargate"
      ecs_desired_count               = 1
      ecs_network_mode                = "awsvpc"
      enable_application_loadbalancer = false
      essential                       = true
      image_url                       = "729713917879.dkr.ecr.us-west-2.amazonaws.com/ez-mail-fargate-cluster:1"
      enable_auto_scaling             = true
      min_capacity                    = 1
      max_capacity                    = 9
      docker_volume                   = null
      mount_points                    = null
    }
  }

}

#database variable

variable "rds_cluster_definition" {
  description = "The definition of rds"
  type = map(object({
    db_indentifier                      = string
    db_engine                           = string
    db_engine_version                   = string
    db_instance_class                   = string
    allocated_storage                   = number
    max_allocated_storage               = number
    db_name                             = string
    db_username_login                   = string
    db_port                             = string
    iam_database_authentication_enabled = bool
    multi_az                            = bool
    backup_retention_period             = number
    db_parameter_family_group           = string
    major_engine_version                = string
    deletion_protection                 = bool
    cross_region_replica                = bool
    publicly_accessible                 = bool
    apply_immediately                   = bool
    storage_encrypted                   = bool
    storage_type                        = string
    delete_automated_backups            = bool
    create_db_option_group              = bool
    option_group_timeouts               = map(string)
    enable_ssm_storage_sensitive_data   = bool
  }))
  default = {
    "mysql" = {
      db_indentifier                      = "ezappservices"
      db_engine                           = "mariadb"
      db_engine_version                   = "10.5.12"
      db_instance_class                   = "db.t3.medium"
      allocated_storage                   = 50
      max_allocated_storage               = 100
      db_name                             = "ezappdb"
      db_username_login                   = "ezappdbadmin"
      db_port                             = "3306"
      iam_database_authentication_enabled = false
      multi_az                            = false
      backup_retention_period             = 30
      db_parameter_family_group           = "mariadb10.5"
      major_engine_version                = "10.5"
      deletion_protection                 = false #for dev mode
      cross_region_replica                = false
      publicly_accessible                 = false
      apply_immediately                   = true
      storage_encrypted                   = true
      storage_type                        = "gp2"
      delete_automated_backups            = true
      create_db_option_group              = false
      option_group_timeouts = {
        "delete" : "5m"
      }
      enable_ssm_storage_sensitive_data = true
    }
  }
}


#bastion variable
variable "bastion_definition" {
  description = "The definition of bastion instance"
  type = map(object({
    is_bastion_vm                   = bool
    bastion_name                    = string
    bastion_public_key              = string
    bastion_ami                     = string
    bastion_instance_class          = string
    user_data_base64                = string
    associate_public_ip_address     = bool
    bastion_monitoring              = bool
    disable_api_termination         = bool
    enable_application_loadbalancer = map(string)
    ingress_rules = map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = set(string)
      description = string
    }))
    egress_rules = map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = set(string)
      description = string
    }))
  }))
  default = {
    "bastion" = {
      is_bastion_vm                   = true
      associate_public_ip_address     = true
      bastion_ami                     = null
      bastion_instance_class          = "t2.small"
      bastion_monitoring              = true
      bastion_name                    = "ez-services-bastion"
      bastion_public_key              = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfgkVcyp2O3BEK4pIBOc1LrJ05bNAj4Sh0DVc2LEZSdEi0XYo44kW7oz3y2YvCozhpjKe8mWMwa7WtjuF7jLdDT7T8LQcYWnDJLdIsQ8RTJ68S8AwjmuwoSHf5hZ3K1aklA1HC+Ub8kyYW8RdVK/xBolrrN0syZIOQR4PkDjV9U9KSSH5a9sz8b32MSE4ZR9BtZdggYbw2GHs8XVD1ySuI7nCMIA1nfEJMC5cyV+LnbeLJNINph3enXPOh3BN0BL54IykEQUzT51ApMM+yWcyHiFV8NQWfjagvTzSEKf92btz3mGcaVMovHXjuBkt/6vyxIIlvEQiWmrZpr0RtRjMd rsa-key-20211210"
      user_data_base64                = null
      disable_api_termination         = false
      enable_application_loadbalancer = null
      ingress_rules = {
        "ssh" = {
          cidr_blocks = ["14.224.131.237/32"]
          from_port   = 22
          protocol    = "tcp"
          to_port     = 22
          description = "Allow trusted ip for ssh only"

        },
        "openvpn" = {
          cidr_blocks = ["14.224.131.237/32"]
          from_port   = 1194
          protocol    = "-1"
          to_port     = 1194
          description = "Allow trusted ip for openvpn only"
        }
      }
      egress_rules = {
        "all" = {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = 0
          protocol    = "-1"
          to_port     = 0
          description = "All expose to all-all"

        }
      }
    },
    "crowd" = {
      is_bastion_vm               = false
      associate_public_ip_address = false
      bastion_ami                 = null
      bastion_instance_class      = "t2.medium"
      bastion_monitoring          = true
      bastion_name                = "ez-services-crowd"
      bastion_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfgkVcyp2O3BEK4pIBOc1LrJ05bNAj4Sh0DVc2LEZSdEi0XYo44kW7oz3y2YvCozhpjKe8mWMwa7WtjuF7jLdDT7T8LQcYWnDJLdIsQ8RTJ68S8AwjmuwoSHf5hZ3K1aklA1HC+Ub8kyYW8RdVK/xBolrrN0syZIOQR4PkDjV9U9KSSH5a9sz8b32MSE4ZR9BtZdggYbw2GHs8XVD1ySuI7nCMIA1nfEJMC5cyV+LnbeLJNINph3enXPOh3BN0BL54IykEQUzT51ApMM+yWcyHiFV8NQWfjagvTzSEKf92btz3mGcaVMovHXjuBkt/6vyxIIlvEQiWmrZpr0RtRjMd rsa-key-20211210"
      user_data_base64            = null
      disable_api_termination     = false
      enable_application_loadbalancer = {
        "enable_alb" : true,
        "port_expose" : 8095
      }
      egress_rules = {
        "all" = {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = 0
          protocol    = "-1"
          to_port     = 0
          description = "All expose to all-all"
        }

      }
      ingress_rules = {
        "ssh" = {
          cidr_blocks = null
          from_port   = 22
          protocol    = "tcp"
          to_port     = 22
          description = "Allow trusted ip for ssh only"
        },
        "application" = {
          cidr_blocks = null
          from_port   = 8095
          to_port     = 8095
          protocol    = "tcp"
          description = "Allow alb access only"
        }
      }
    }
  }
}
