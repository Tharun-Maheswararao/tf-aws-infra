# S3 Bucket
resource "aws_s3_bucket" "uploads" {
  bucket        = uuid()
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "uploads_ownership" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads_lifecycle" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "transition_rule"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}