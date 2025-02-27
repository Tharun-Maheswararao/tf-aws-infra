resource "aws_instance" "webapp_instance" {
  ami                         = var.new_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnets["vpc1-0"].id # Use a public subnet from your VPC
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  associate_public_ip_address = true

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

              echo "Starting webapp service..."
              sudo systemctl enable webapp
              sudo systemctl start webapp

              echo "Checking service status..."
              sudo systemctl status webapp --no-pager

              echo "Setup completed!"
            EOF


  tags = {
    Name = "webapp-ec2-instance"
  }
}
