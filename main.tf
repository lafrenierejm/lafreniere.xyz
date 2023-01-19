locals {
  domain       = "lafreniere.xyz"
  s3_origin_id = "lafreniere.xyz" # TODO
  ttl          = 300              # seconds
}

# DNS
resource "aws_route53_zone" "root" {
  name = local.domain
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
resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.root.name
  type    = "SPF"
  ttl     = local.ttl
  records = [
    "v=spf1 include:spf.messagingengine.com ?all",
  ]
}

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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control
# Manages an AWS CloudFront Origin Access Control, which is used by CloudFront Distributions with an Amazon S3 bucket as the origin.
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = local.domain
  description                       = local.domain
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

output "s3_uri" {
  value = "s3://${aws_s3_bucket.lafreniere_xyz.id}"
}
