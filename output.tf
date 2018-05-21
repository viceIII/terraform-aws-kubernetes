output minions {
  value = ["${aws_instance.minion.*.id}"]
}

output master_private_ip {
  value = "${element(aws_instance.master.*.private_ip, 0)}"
}

output minion_security_group {
  value = "${aws_security_group.minions.id}"
}

output minion_elb_dns_name {
  value = "${aws_elb.minion.dns_name}"
}

output minion_elb_zone_id {
  value = "${aws_elb.minion.zone_id}"
}

output minion_elb_id {
  value = "${aws_elb.minion.id}"
}

output minion_aws_iam_instance_profile_name {
  value = "${aws_iam_instance_profile.minions.name}"
}

output minion_elb_tcp_dns_name {
  value = "${join(" ", aws_elb.minion-tcp.*.dns_name)}"
}

output minion_elb_tcp_zone_id {
  value = "${join(" ", aws_elb.minion-tcp.*.zone_id)}"
}
