variable cluster_name {
  description = "The name of the cluster; will be used to tag objects in AWS.  Each cluster should have a different name to allow multiple clusters to exist in the same AWS region / account."
}

variable vpc_cidr_block {
  default = "172.20.0.0/16"
}

variable minion_security_groups {
  type    = "list"
  default = []
}

variable master_security_groups {
  type    = "list"
  default = []
}

variable root_domain {}

variable root_volume_size {
  default = 100
}

variable vpc_id {}

variable minions_public_ports {
  type    = "list"
  default = []
}

variable vpc_subnet_ids_list {
  type = "list"
}

variable container_cidr_block {
  default = "10.244.0.0/16"
}

variable ami {
  // Ubuntu xenial 16.04, instance store, HVM
  // See https://cloud-images.ubuntu.com/locator/ec2/ for others.
  // HVM, ebs-root only please.
  default = ""
}

variable master_instance_type {
  default = "m4.large"
}

variable master_user_data {
  default = ""
}

variable minion_user_data {
  default = ""
}

variable minion_instance_type {
  default = "m4.xlarge"
}

variable num_azs {
  default = "1"
}

variable key_pair_name {
  default = "kubernetes-key-pair"
}

variable iam_suffix {
  default = ""
}

variable support_nat {
  default = true
}

variable num_masters {
  default = 1
}

variable num_minions {
  default = 3
}

variable enable_extra_minion_security_group {
  default = false
}

variable extra_minion_security_group {
  description = "Extra security groups that will be allow to talk to the minions"
  default     = ""
}

variable extra_minion_security_group_port {
  description = "Port on which the extra security groups that will be allow to talk to the minions"
  default     = 80
}

variable elb_name {
  type    = "string"
  default = "kubernetes-master"
}
