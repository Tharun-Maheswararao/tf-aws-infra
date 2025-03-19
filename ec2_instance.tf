resource "aws_instance" "webapp_instance" {
  ami                         = var.new_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnets["vpc1-0"].id # Use a public subnet from your VPC
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1  # Capture logs
              set -x  # Debugging enabled

              echo "Updating instance..."
              sudo apt update -y

              echo "Fetching Database and S3 details from AWS SSM..."
              DB_HOST=${aws_db_instance.db_instance.address}
              S3_BUCKET=${aws_s3_bucket.uploads.bucket}

              echo "Updating app.config..."
              cat <<EOT | sudo tee /opt/webapp/app/app.config > /dev/null
              [DATABASE]
              DB_CONNECTION=mysql
              DB_HOST=$DB_HOST
              DB_PORT=3306
              DB_NAME=${var.db_name}
              DB_USERNAME=${var.db_username}
              DB_PASSWORD=${var.db_password}
              

              [S3]
              S3_BUCKET=$S3_BUCKET
              AWS_REGION=us-east-1
              EOT

              echo "Starting webapp service..."
              sudo systemctl enable webapp
              sudo systemctl start webapp

              echo "Checking service status..."
              sudo systemctl status webapp --no-pager

              echo "Setup completed!"
            EOF


  tags = {
    Name        = "${var.environment}-webapp-instance"
    Environment = var.environment
  }
}
