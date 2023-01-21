locals {
  domain = "lafreniere.xyz"
  ttl    = 300 # seconds
}

# DNS
resource "aws_route53_zone" "root" {
  name = local.domain
}

## Web
resource "aws_route53_record" "www" {
  for_each = toset(["A", "AAAA"])

  zone_id = aws_route53_zone.root.zone_id
  name    = local.domain
  type    = each.value

  # https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html#routing-to-cloudfront-distribution-config
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

## Mail
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.root.name
  type    = "MX"
  ttl     = local.ttl
  records = [
    "10 in1-smtp.messagingengine.com.",
    "20 in2-smtp.messagingengine.com.",
  ]
}

resource "aws_route53_record" "imaps" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "_imaps._tcp.${aws_route53_zone.root.name}"
  type    = "SRV"
  ttl     = local.ttl
  records = [
    "0 1 993 imap.fastmail.com."
  ]
}

resource "aws_route53_record" "submission" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "_submission._tcp.${aws_route53_zone.root.name}"
  type    = "SRV"
  ttl     = local.ttl
  records = [
    "0 1 587 smtp.fastmail.com."
  ]
}

## SPF
resource "aws_route53_record" "spf_txt" {
  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.root.name
  type    = "TXT"
  ttl     = local.ttl
  records = [
    "v=spf1 include:spf.messagingengine.com ?all"
  ]
}

## DKIM
resource "aws_route53_record" "domainkey" {
  count = 3

  zone_id = aws_route53_zone.root.zone_id
  name    = "fm${count.index + 1}._domainkey.${aws_route53_zone.root.name}"
  type    = "CNAME"
  ttl     = local.ttl

  records = [
    "fm${count.index + 1}.${aws_route53_zone.root.name}.dkim.fmhosted.com."
  ]
}

# Certificate
resource "aws_acm_certificate" "lafreniere_xyz" {
  domain_name               = local.domain
  subject_alternative_names = ["*.${local.domain}"]
  validation_method         = "DNS"

  tags = {
    Name = local.domain
  }

  lifecycle {
    create_before_destroy = true
  }
}

## CAA
resource "aws_route53_record" "caa" {
  name = aws_route53_zone.root.name
  type = "CAA"
  ttl  = local.ttl
  records = [
    for ca in [
      "amazon.com",
      "amazonaws.com",
      "amazontrust.com",
      "awstrust.com",
    ] :
    join(" ", ["0", "issue", "\"${ca}\""])
  ]
  zone_id = aws_route53_zone.root.zone_id
}

## Add the DNS record for validation.
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.lafreniere_xyz.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = local.ttl
  type            = each.value.type
  zone_id         = aws_route53_zone.root.zone_id
}

## Wait for the certificate to validate.
resource "aws_acm_certificate_validation" "lafreniere_xyz" {
  for_each = aws_route53_record.acm_validation

  certificate_arn         = aws_acm_certificate.lafreniere_xyz.arn
  validation_record_fqdns = [each.value.fqdn]
}

# S3
resource "aws_s3_bucket" "lafreniere_xyz" {
  bucket = local.domain
  tags = {
    Name = local.domain
  }
}

resource "aws_s3_bucket_acl" "lafreniere_xyz" {
  bucket = aws_s3_bucket.lafreniere_xyz.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "lafreniere_xyz" {
  bucket = aws_s3_bucket.lafreniere_xyz.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## Allow CloudFront access to the bucket.
resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.lafreniere_xyz.id
  policy = data.aws_iam_policy_document.access_s3_from_cloudfront.json
}

data "aws_iam_policy_document" "access_s3_from_cloudfront" {
  statement {
    sid = "AllowCloudfrontServicePrincipal"
    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.lafreniere_xyz.arn}/*"
    ]
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.s3_distribution.arn,
      ]
    }
  }
}


# CloudFront

## Lookup the issued certificate.
data "aws_acm_certificate" "root" {
  domain      = local.domain
  most_recent = true
}

## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control
## Manages an AWS CloudFront Origin Access Control, which is used by CloudFront Distributions with an Amazon S3 bucket as the origin.
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = local.domain
  description                       = local.domain
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
## Create an Amazon CloudFront web distribution.
resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_acm_certificate_validation.lafreniere_xyz]

  aliases = [
    local.domain,
    "www.${local.domain}",
  ]
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    forwarded_values {
      cookies {
        forward = "all"
      }
      query_string = true
    }
    target_origin_id       = aws_s3_bucket.lafreniere_xyz.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
  }
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http3"

  origin {
    domain_name              = aws_s3_bucket.lafreniere_xyz.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = aws_s3_bucket.lafreniere_xyz.bucket_regional_domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.root.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

output "s3_uri" {
  value = "s3://${aws_s3_bucket.lafreniere_xyz.id}"
}
