resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "*.yourdomain.net"
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}