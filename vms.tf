resource "aws_instance" "master" {
  count = "${var.num_masters}"

  lifecycle {
    prevent_destroy = false
  }

  disable_api_termination = false

  ami                  = "${var.ami == "" ? data.aws_ami.default.id : var.ami}"
  instance_type        = "${var.master_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.master.name}"
  key_name             = "${var.key_pair_name}"

  tags {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "${var.cluster_name}-master"
    Role              = "${var.cluster_name}-master"
  }

  associate_public_ip_address = true
  user_data                   = "${var.master_user_data}"

  // Allows the VM to masquerade IPs (for pods). Otherwise, the
  // AWS runtime restricts the VM traffic to only appear as its
  // own IP.
  source_dest_check = false

  subnet_id              = "${element(var.vpc_subnet_ids_list, count.index % length(data.aws_availability_zones.available.names))}"
  availability_zone      = "${element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))}"
  vpc_security_group_ids = ["${aws_security_group.masters.id}"]

  ephemeral_block_device {
    device_name  = "/dev/xvdb"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name  = "/dev/xvdc"
    virtual_name = "ephemeral1"
  }

  root_block_device {
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }
}

resource "aws_instance" "minion" {
  count = "${var.num_minions}"

  lifecycle {
    prevent_destroy = false
  }

  disable_api_termination = false

  ami                  = "${var.ami == "" ? data.aws_ami.default.id : var.ami}"
  instance_type        = "${var.minion_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.minions.name}"
  key_name             = "${var.key_pair_name}"

  tags {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "${var.cluster_name}-minion"
    Role              = "${var.cluster_name}-minion"
  }

  root_block_device {
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  associate_public_ip_address = true

  // Allows the VM to masquerade IPs (for pods). Otherwise, the
  // AWS runtime restricts the VM traffic to only appear as its
  // own IP.
  source_dest_check = false

  subnet_id              = "${element(var.vpc_subnet_ids_list, count.index % length(data.aws_availability_zones.available.names))}"
  availability_zone      = "${element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))}"
  vpc_security_group_ids = ["${aws_security_group.minions.id}"]

  user_data = "${var.minion_user_data}"

  ephemeral_block_device {
    device_name  = "/dev/xvdb"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name  = "/dev/xvdc"
    virtual_name = "ephemeral1"
  }
}

resource "aws_iam_instance_profile" "minions" {
  name = "kubernetes-minion${var.iam_suffix}"
  role = "${aws_iam_role.minion.name}"
}

resource "aws_iam_instance_profile" "master" {
  name = "kubernetes-master${var.iam_suffix}"
  role = "${aws_iam_role.master.name}"
}

resource "aws_iam_role" "minion" {
  name = "kubernetes-minion${var.iam_suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "master" {
  name = "kubernetes-master${var.iam_suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "minion" {
  name = "kubernetes-minion"
  role = "${aws_iam_role.minion.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::kubernetes-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:AttachVolume",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DetachVolume",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "master" {
  name = "kubernetes-master"
  role = "${aws_iam_role.master.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::kubernetes-*"
      ]
    }
  ]
}
EOF
}
