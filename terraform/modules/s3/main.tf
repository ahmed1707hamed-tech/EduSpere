locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for ${local.name_prefix} S3 bucket encryption."
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-s3-kms"
  })
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${local.name_prefix}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket        = each.value.name
  force_destroy = each.value.force_destroy

  tags = merge(local.common_tags, each.value.tags, {
    Name      = each.value.name
    Purpose   = each.key
    DataClass = each.value.data_class
  })
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = var.buckets[each.key].versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.buckets[each.key].sse_algorithm == "aws:kms" ? aws_kms_key.s3.arn : null
      sse_algorithm     = var.buckets[each.key].sse_algorithm
    }
    bucket_key_enabled = var.buckets[each.key].bucket_key_enabled
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    id     = "enterprise-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_transition {
      noncurrent_days = var.buckets[each.key].noncurrent_transition_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.buckets[each.key].noncurrent_expiration_days
    }

    dynamic "transition" {
      for_each = var.buckets[each.key].transition_days == null ? [] : [var.buckets[each.key].transition_days]
      content {
        days          = transition.value
        storage_class = "STANDARD_IA"
      }
    }

    dynamic "expiration" {
      for_each = var.buckets[each.key].expiration_days == null ? [] : [var.buckets[each.key].expiration_days]
      content {
        days = expiration.value
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_dynamodb_table" "terraform_locks" {
  count = var.create_terraform_lock_table ? 1 : 0

  name         = var.terraform_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.s3.arn
  }

  tags = merge(local.common_tags, {
    Name    = var.terraform_lock_table_name
    Purpose = "terraform-state-locking"
  })
}
