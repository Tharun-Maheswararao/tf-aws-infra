resource "aws_launch_template" "webapp_lt" {
  name_prefix   = "${var.environment}-webapp-lt"
  image_id      = var.new_ami
  instance_type = "t2.micro"
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.public_subnets["vpc1-0"].id
    security_groups             = [aws_security_group.application_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    exec > /var/log/user-data.log 2>&1
    set -x

    echo "Updating instance..."
    sudo apt update -y

    # Install AWS CLI if not already installed
              if ! command -v aws &> /dev/null; then
                echo "Installing AWS CLI..."
                sudo apt-get update
                sudo apt-get install -y unzip curl
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install
                rm -rf aws awscliv2.zip
              fi


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
    DB_PASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id db-password-temp-2 \
    --query SecretString \
    --output text \
    --region us-east-1)

    [S3]
    S3_BUCKET=$S3_BUCKET
    AWS_REGION=us-east-1
    EOT

    echo "Starting webapp service..."
    sudo systemctl enable webapp
    sudo systemctl start webapp

    echo "Checking service status..."
    sudo systemctl status webapp --no-pager

    echo "Configuring CloudWatch Agent..."
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
      -s

    echo "Checking CloudWatch Agent status..."
    sudo systemctl status amazon-cloudwatch-agent --no-pager

    echo "Setup completed!"
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-webapp-instance"
      Environment = var.environment
    }
  }
}
