# IAM Role & Policy for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy-for-webapp"
  description = "Allows EC2 instance to access S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Effect = "Allow"
      Resource = [
        aws_s3_bucket.uploads.arn,
        "${aws_s3_bucket.uploads.arn}/*"
      ]
    }]
  })
}

# IAM Policy for RDS Access
resource "aws_iam_policy" "rds_access_policy" {
  name        = "rds-access-policy-for-webapp"
  description = "Allows EC2 instance to describe RDS instances"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "rds:DescribeDBInstances"
      ]
      Effect   = "Allow"
      Resource = aws_db_instance.db_instance.arn
    }]
  })
}

# IAM Policy for CloudWatch
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwatch-policy-for-webapp-v2"
  description = "Allows EC2 instance to send logs and metrics to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "CSYE6225/WebApp"
          }
        }
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:csye6225-app-logs:*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:csye6225-error-logs:*"
        ]
      }
    ]
  })
}

# IAM Policy for Auto-Scaling and Load Balancer Access
resource "aws_iam_policy" "autoscaling_lb_policy" {
  name        = "autoscaling-lb-policy-for-webapp"
  description = "Allows EC2 instances to register with the load balancer and auto-scaling"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:Describe*",
          "autoscaling:CompleteLifecycleAction"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:autoscaling:${var.aws_region}:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/csye6225-asg"
      },
      {
        Action = [
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]
        Effect = "Allow"
        Resource = [
          aws_lb.webapp_lb.arn,
          aws_lb_target_group.webapp_tg.arn
        ]
      }
    ]
  })
}

# IAM Policy for KMS Access - Updated with expanded permissions
resource "aws_iam_policy" "kms_access_policy" {
  name        = "kms-access-policy-for-webapp"
  description = "Allows EC2 instance to use KMS keys"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:CreateKey",
          "kms:TagResource",
          "kms:GetKeyPolicy"
        ]
        Effect = "Allow"
        Resource = [
          aws_kms_key.ec2_key.arn,
          aws_kms_key.rds_key.arn,
          aws_kms_key.s3_key.arn,
          aws_kms_key.secrets_key.arn
        ]
      },
      {
        Sid    = "AllowKMSAliasAndManagement",
        Effect = "Allow",
        Action = [
          "kms:CreateKey",
          "kms:ListKeys",
          "kms:ListAliases",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:UpdateAlias",
          "kms:DescribeKey",
          "kms:GetKeyPolicy",
          "kms:PutKeyPolicy",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:EnableKey",
          "kms:DisableKey",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for Secrets Manager Access
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets-manager-policy-for-webapp"
  description = "Allows EC2 instance to access Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.rds_password.arn
      }
    ]
  })
}

resource "aws_iam_policy" "acm_management_policy" {
  name        = "acm-management-policy-for-webapp"
  description = "Allows ACM certificate management"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowACMFullManagement",
        Effect = "Allow",
        Action = [
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "acm:DeleteCertificate",
          "acm:RequestCertificate",
          "acm:AddTagsToCertificate",
          "acm:RemoveTagsFromCertificate"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_access_policy" {
  name        = "ssm-access-policy-for-webapp"
  description = "Allows EC2 instance to access SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/webapp/*"
      }
    ]
  })
}



# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile-for-webapp"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}


resource "aws_iam_user_policy_attachment" "attach_acm_management_policy" {
  user       = var.aws_profile
  policy_arn = aws_iam_policy.acm_management_policy.arn
}


# Attach Policies to Role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_rds_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.rds_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_autoscaling_lb_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.autoscaling_lb_policy.arn
}

# Attach KMS Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "attach_kms_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.kms_access_policy.arn
}

resource "aws_iam_user_policy_attachment" "attach_kms_access_policy" {
  user       = var.aws_profile
  policy_arn = aws_iam_policy.kms_access_policy.arn
}


resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Ensure the Auto Scaling service-linked role exists
# This is typically created automatically by AWS, but we're making it explicit
resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "Default Service-Linked Role for Auto Scaling"
  # The count=0 is to prevent creating it if it already exists
  # Set count=1 if you need to create it
  count = 0
}

# KMS grant for the Auto Scaling service-linked role
resource "aws_kms_grant" "asg_grant" {
  name              = "asg-grant-for-ec2"
  key_id            = aws_kms_key.ec2_key.id
  grantee_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  operations = [
    "Encrypt",
    "Decrypt",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "ReEncryptFrom",
    "ReEncryptTo",
    "CreateGrant",
    "DescribeKey"
  ]

  # Ensure this is created after the KMS key
  depends_on = [aws_kms_key.ec2_key]
}
