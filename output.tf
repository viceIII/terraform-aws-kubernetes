output minions {
  value = ["${aws_instance.minion.*.id}"]
}

output minion_security_group {
  value = "${aws_security_group.minions.id}"
}
