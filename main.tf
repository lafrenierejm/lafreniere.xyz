locals {
  domain       = "lafreniere.xyz"
  s3_origin_id = "lafreniere.xyz" # TODO
}

# DNS
resource "aws_route53_zone" "root" {
  name = local.domain
}

resource "aws_route53_zone" "www" {
  name = "www.${local.domain}"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.www.name
  type    = "NS"
  ttl     = 300 # seconds
  records = aws_route53_zone.www.name_servers
}

## Mail
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "mx-primary"
  type    = "MX"
  ttl     = 300 # seconds
  records = [
    "10 in1-smtp.messagingengine.com.",
    "20 in2-smtp.messagingengine.com.",
  ]
}

resource "aws_route53_record" "mx-spf" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "mx-spf"
  type    = "TXT"
  ttl     = 300 # seconds
  records = ["@v=spf1 include:spf.messagingengine.com ?all"]
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
  name                              = "lafreniere.xyz"
  description                       = "lafreniere.xyz"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

output "s3_uri" {
  value = "s3://${aws_s3_bucket.lafreniere_xyz.id}"
}
