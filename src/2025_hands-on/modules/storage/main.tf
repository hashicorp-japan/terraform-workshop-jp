resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "an example bucket"
  }
}

/*
 * Continuous validation sample codes
 */
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.example_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

check "s3_bucket_encryption" {
  assert {
    condition = contains([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      rule.apply_server_side_encryption_by_default.sse_algorithm
    ], "AES256")
    error_message = "S3 bucket is not encrypted"
  }
}