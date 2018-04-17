data "aws_acm_certificate" "root_cert" {
  domain = "${var.root_domain}"

  # most_recent = true
  statuses = ["ISSUED", "PENDING_VALIDATION"]
}
