locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_cloudfront_origin_access_control" "s3" {
  for_each = var.s3_origins

  name                              = "${local.name_prefix}-${each.key}-oac"
  description                       = "Origin access control for ${each.key}."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = "EduSphere distribution for ${local.name_prefix}."
  aliases             = var.aliases
  price_class         = var.price_class
  default_root_object = var.default_root_object
  web_acl_id          = var.web_acl_id

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = var.alb_origin_protocol_policy
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  dynamic "origin" {
    for_each = var.s3_origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.key
      origin_access_control_id = aws_cloudfront_origin_access_control.s3[origin.key].id
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    forwarded_values {
      query_string = true
      headers      = var.alb_forwarded_headers

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = var.alb_default_ttl
    max_ttl     = var.alb_max_ttl
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.s3_origins
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.key
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      compress               = true

      forwarded_values {
        query_string = false

        cookies {
          forward = "none"
        }
      }

      min_ttl     = var.s3_min_ttl
      default_ttl = var.s3_default_ttl
      max_ttl     = var.s3_max_ttl
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = var.minimum_protocol_version
    ssl_support_method       = "sni-only"
  }

  logging_config {
    bucket          = var.logging_bucket_domain_name
    include_cookies = false
    prefix          = var.logging_prefix
  }

  tags = local.common_tags
}

data "aws_iam_policy_document" "s3_origin" {
  for_each = var.s3_origins

  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = ["${each.value.bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_origin" {
  for_each = var.s3_origins

  bucket = each.value.bucket_id
  policy = data.aws_iam_policy_document.s3_origin[each.key].json
}
