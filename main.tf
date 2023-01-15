locals {
  domain = "lafreniere.xyz"
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
