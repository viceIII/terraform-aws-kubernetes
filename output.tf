output minions {
  value = ["${aws_instance.minion.*.id}"]
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
