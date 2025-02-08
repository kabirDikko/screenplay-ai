resource "aws_s3_bucket" "knowledge_base_bucket" {
  bucket = "knowledge-base-bucket"

  tags = {
    Name        = "Knowledge Base Bucket"
    Managed-By  = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "knowledge_base_bucket_acl" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "knowledge_base_bucket_encryption" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "knowledge_base_bucket_versioning" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
