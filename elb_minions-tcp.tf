// ELB for the k8s API
resource "aws_elb" "minion-tcp" {
  count           = "${var.minion_tcp_elb_enabled ? 1 : 0}"
  name            = "${var.elb_name}-minion-tcp"
  subnets         = ["${var.vpc_subnet_ids_list}"]
  security_groups = ["${aws_security_group.minion-elb.id}"]

  tags {
    KubernetesCluster = "${var.cluster_name}"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "${data.aws_acm_certificate.root_cert.arn}"
  }

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    // The number of checks before the instance is declared healthy.
    healthy_threshold = 2

    // The number of checks before the instance is declared unhealthy.
    unhealthy_threshold = 6

    // In seconds
    timeout = 5

    // In seconds
    interval = 10

    target = "TCP:80"
  }

  instances = ["${aws_instance.minion.*.id}"]
}
