resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/webapp/rds_endpoint"
  type  = "String"
  value = aws_db_instance.db_instance.endpoint
}

resource "aws_ssm_parameter" "s3_bucket" {
  name  = "/webapp/s3_bucket"
  type  = "String"
  value = aws_s3_bucket.uploads.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}

output "s3_bucket" {
  value = aws_s3_bucket.uploads.bucket
}

# output "ec2_iam_role" {
#   value = aws_iam_role.ec2_cloudwatch_role.name
# }