data "aws_availability_zones" "available" {}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name              = "kubernetes-dhcp-option-set"
    KubernetesCluster = "${var.cluster_name}"
  }
}

// TODO: we can seem to import this
// resource "aws_vpc_dhcp_options_association" "main" {
//     vpc_id = "${aws_vpc.main.id}"
//     dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
// }

resource "aws_network_acl" "main" {
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${var.vpc_id}"

  tags {
    KubernetesCluster = "${var.cluster_name}"
  }
}

resource "aws_route" "master-route" {
  count          = "${var.num_masters}"
  route_table_id = "${aws_route_table.main.id}"

  destination_cidr_block = "${cidrsubnet(var.container_cidr_block, 8, 100 + count.index)}"
  instance_id            = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_route" "minion-route" {
  count          = "${var.num_minions}"
  route_table_id = "${aws_route_table.main.id}"

  # - VMs are round robined amongst AZs
  # - Each AZ gets a range of 25 subnets for pod routing:
  #     [x.x.254.0, x.x.229.0) -> AZ 1
  #     [x.x.229.0, x.x.204.0) -> AZ 2
  # - Within each AZ, each host gets one of the subnets,
  #   counting down within the range
  #     x.x.254.0 -> host 1, AZ 1
  #     x.x.253.0 -> host 2, AZ 1
  #     x.x.229.0 -> host 1, AZ 2
  #     etc

  destination_cidr_block = "${cidrsubnet(var.container_cidr_block, 8, 254 - (25 * (count.index % length(data.aws_availability_zones.available.names))) - (count.index / length(data.aws_availability_zones.available.names)))}"
  instance_id            = "${element(aws_instance.minion.*.id, count.index)}"
}
