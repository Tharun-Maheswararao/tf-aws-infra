# IAM Role & Policy for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_rds_policy" {
  name        = "s3_rds_policy"
  description = "Allows EC2 to access S3 & RDS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"],
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect   = "Allow"
        Action   = ["rds:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.s3_rds_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "ssm_read_policy" {
  name        = "EC2SSMReadPolicy"
  description = "Allows EC2 to read SSM parameters"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ]
        Resource = "arn:aws:ssm:us-east-1:${var.aws_account_id}:parameter/webapp/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_read_policy_attach" {
  policy_arn = aws_iam_policy.ssm_read_policy.arn
  role       = aws_iam_role.ec2_role.name
}

