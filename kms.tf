resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 volumes"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:user/a4githubactions"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:CreateGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = true
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:user/a4githubactions"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:CreateGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = true
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 Buckets"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:user/a4githubactions"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:CreateGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = true
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for Secrets Manager (DB Password & Email Credentials)"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:user/a4githubactions"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:CreateGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = true
          }
        }
      }
    ]
  })
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "db-password-temp-2"
  description = "Auto-generated DB password"
  kms_key_id  = aws_kms_key.secrets_key.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:user/a4githubactions"
        },
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:PutResourcePolicy",
          "secretsmanager:RestoreSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_key" "example" {
  description             = "KMS key example"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::241533141323:user/a4githubactions"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

# Set the secret value
resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# Output the secret string (optional, sensitive)
output "db_password_value" {
  value     = aws_secretsmanager_secret_version.db_password_version.secret_string
  sensitive = true
}