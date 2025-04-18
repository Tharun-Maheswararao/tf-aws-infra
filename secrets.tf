# Generate a random password for RDS
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|;:,.<>?" # Excludes '/', '@', '"', and space
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

# Store RDS Password in Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "rds-password"
  description             = "RDS database password"
  kms_key_id              = aws_kms_key.secrets_key.arn
  recovery_window_in_days = 0 # Allows immediate deletion for testing

  # Add explicit dependency
  depends_on = [aws_kms_key.secrets_key]

  tags = {
    Name = "tf-rds-password-secret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.rds_password.result

  # Add explicit dependency
  depends_on = [aws_secretsmanager_secret.rds_password]
}