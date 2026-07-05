locals {
  tags = merge(
    {
      Project = var.project_name
      Managed = "terraform"
      Module  = "s3"
    },
    var.tags
  )

  prefix = length(trimspace(var.bucket_prefix)) > 0 ? var.bucket_prefix : var.project_name

  buckets = {
    course_videos    = "${local.prefix}-course-videos"
    course_materials = "${local.prefix}-course-materials"
    certificates     = "${local.prefix}-certificates"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets

  bucket = each.value
  tags   = merge(local.tags, { Name = each.value })
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = var.lifecycle_expire_days > 0 ? aws_s3_bucket.this : {}

  bucket = each.value.id

  rule {
    id     = "lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.lifecycle_expire_days
    }
  }
}