locals {
  domain = "lafreniere.xyz"
  ttl    = 86400 # 1 day
}

data "aws_caller_identity" "current" {}

# DNS
resource "aws_route53_zone" "root" {
  name = local.domain
}

## Route53 only permits one TXT resource per name, so we need to put all values in it.
resource "aws_route53_record" "txt" {
  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.root.name
  type    = "TXT"
  ttl     = local.ttl
  records = [
    # sender policy framework (SPF)
    "v=spf1 include:spf.messagingengine.com ?all",

    # Ethereum Name Service (ENS)
    "ENS1 dnsname.ens.eth 0xc13ED920b46e2a765c22abAd6e401fbeB213B85A",
  ]
}

## Web
resource "aws_route53_record" "apex" {
  for_each = toset(["A", "AAAA"])

  zone_id = aws_route53_zone.root.zone_id
  name    = local.domain
  type    = each.value

  alias {
    name    = aws_route53_record.www[each.key].name
    zone_id = aws_route53_record.www[each.key].zone_id

    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  for_each = toset(["A", "AAAA"])

  zone_id = aws_route53_zone.root.zone_id
  name    = "www.${local.domain}"
  type    = each.value

  # https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html#routing-to-cloudfront-distribution-config
  alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id

    evaluate_target_health = false
  }
}

## Mail
## https://www.fastmail.help/hc/en-us/articles/360060591153-Manual-DNS-configuration
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

resource "aws_route53_record" "srv" {
  for_each = {
    submission = {
      priority = 0
      weight   = 1
      port     = 587
      target   = "smtp.fastmail.com"
    }
    imap = {
      priority = 0
      weight   = 0
      port     = 0
      target   = "."
    }
    imaps = {
      priority = 0
      weight   = 1
      port     = 993
      target   = "imap.fastmail.com"
    }
    pop3 = {
      priority = 0
      weight   = 0
      port     = 0
      target   = "."
    }
    pop3s = {
      priority = 10
      weight   = 1
      port     = 995
      target   = "pop.fastmail.com"
    }
    jmap = {
      priority = 0
      weight   = 1
      port     = 443
      target   = "api.fastmail.com"
    }
  }

  zone_id = aws_route53_zone.root.zone_id
  name    = "_${each.key}._tcp.${aws_route53_zone.root.name}"
  type    = "SRV"
  ttl     = local.ttl
  records = [
    join(" ", [each.value.priority, each.value.weight, each.value.port, each.value.target])
  ]
}

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

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "_dmarc.${aws_route53_zone.root.name}"
  type    = "TXT"
  ttl     = local.ttl
  records = ["v=DMARC1; p=none;"]
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

# DNSSEC
## Key
data "aws_iam_policy_document" "dnssec_key" {
  statement {
    sid = "Allow Route 53 DNSSEC Service"
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
    ]
    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:route53:::hostedzone/*"]
    }
  }

  statement {
    sid     = "Allow Route 53 DNSSEC to CreateGrant"
    actions = ["kms:CreateGrant"]
    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    sid     = "Enable IAM User Permissions"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "lafreniere_xyz_dnssec" {
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy                   = data.aws_iam_policy_document.dnssec_key.json
}

data "aws_kms_public_key" "lafreniere_xyz_dnssec" {
  key_id = aws_kms_key.lafreniere_xyz_dnssec.key_id
}

resource "aws_route53_key_signing_key" "lafreniere_xyz" {
  hosted_zone_id             = aws_route53_zone.root.id
  key_management_service_arn = aws_kms_key.lafreniere_xyz_dnssec.arn
  name                       = local.domain
}

resource "aws_route53_hosted_zone_dnssec" "example" {
  depends_on = [
    aws_route53_key_signing_key.lafreniere_xyz
  ]
  hosted_zone_id = aws_route53_key_signing_key.lafreniere_xyz.hosted_zone_id
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
  http_version        = "http2and3"

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
