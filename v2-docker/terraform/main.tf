locals {
  normalized_environment = lower(var.environment)

  bucket_name = lower(
    coalesce(
      var.s3_bucket_name_override,
      "${var.s3_bucket_base_name}-${local.normalized_environment}"
    )
  )

  default_tags = merge(var.common_tags, {
    Project     = var.project_tag
    Environment = local.normalized_environment
  })
}

resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = var.bucket_force_destroy

  tags = merge(local.default_tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
