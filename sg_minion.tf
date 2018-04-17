resource "aws_security_group" "minion-elb" {
  vpc_id      = "${var.vpc_id}"
  name        = "kubernetes-minion-elb-${var.cluster_name}"
  description = "Kubernetes security group for minion API ELB"

  tags {
    KubernetesCluster = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "minion-elb-allow-https" {
  security_group_id = "${aws_security_group.minion-elb.id}"

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "minion-elb-allow-http" {
  security_group_id = "${aws_security_group.minion-elb.id}"

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "minion-elb-allow-egress" {
  security_group_id = "${aws_security_group.minion-elb.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
