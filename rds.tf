# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow DB access from EC2"
  vpc_id      = aws_vpc.main["vpc1"].id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id]
  }
}

# RDS Subnet Group (Dynamically Fetch Private Subnets)
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "rds-subnet-group"

  # Loop through all private subnets dynamically
  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_parameter_group" "custom_rds_pg" {
  name   = "custom-rds-parameter-group"
  family = "mysql8.0" # Change based on DB engine (e.g., "postgres15", "mariadb10.6")

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  tags = {
    Name = "Custom RDS Parameter Group"
  }
}

# RDS Instance
resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  identifier             = "csye6225"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name   = aws_db_parameter_group.custom_rds_pg.name
  skip_final_snapshot    = true
}