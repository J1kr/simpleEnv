resource "aws_db_parameter_group" "mysql-parameters" {
    name = "${var.name}-params"
    family = "mysql5.7"
    description = "mysql parameter group"

    parameter {
      name = "max_allowed_packet"
      value = "16777216"
   }

    parameter {
      name = "character_set_client"
      value = "utf8"
   }

    parameter {
      name = "character_set_connection"
      value = "utf8"
   }

    parameter {
      name = "character_set_database"
      value = "utf8"
   }

    parameter {
      name = "character_set_filesystem"
      value = "utf8"
   }

    parameter {
      name = "character_set_results"
      value = "utf8"
   }
    
    parameter {
      name = "character_set_server"
      value = "utf8"
   }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20    # 20 GB of storage, gives us more IOPS than a lower number
  engine               = "mysql"
  engine_version       = "5.7.31"
  instance_class       = "db.t2.micro"    # use micro if you want to use the free tier
  identifier           = "${var.name}-mysql"
  name                 = var.rds_name # database name 
  username             = var.rds_username  # username
  password             = var.rds_passwd # password
  db_subnet_group_name = var.subnet_name
  parameter_group_name = aws_db_parameter_group.mysql-parameters.name
  multi_az             = "false"     # set to true to have high availability: 2 instances synchronized with each other
  vpc_security_group_ids = var.security_groups
  storage_type         = "gp2"
  # backup_retention_period = 30    # how long you’re going to keep your backups
  
  skip_final_snapshot = true
  tags = merge(var.tags, map("Name", format("%s-Private", var.name)))
}
