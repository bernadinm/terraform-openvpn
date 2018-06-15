# Create DCOS Mesos Public Agent Scripts to execute
module "dcos-mesos-agent-public" {
  source = "git@github.com:mesosphere/terraform-dcos-enterprise//tf_dcos_core"
  bootstrap_private_ip = "${aws_instance.bootstrap.private_ip}"
  dcos_install_mode    = "${var.state}"
  dcos_version         = "${var.dcos_version}"
  role                 = "dcos-mesos-agent-public"
}

# Reattach the public ELBs to the agents if they change
#resource "aws_elb_attachment" "public-agent-elb" {
#  count    = "${var.num_of_public_agents}"
#  elb      = "${aws_elb.public-agent-elb.id}"
#  # instance = "${aws_instance.public-agent.*.id[count.index]}"
#
#  instances       = ["${aws_instance.public-agent-group-1.*.id}", "${aws_instance.public-agent-group-2.*.id}", "${aws_instance.public-agent-group-3.*.id}"]
#}

# Public Agent Load Balancer Access
# Adminrouter Only
resource "aws_elb" "public-agent-elb" {
  name = "${data.template_file.cluster-name.rendered}-pub-agt-elb"

  subnets         = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.public_slave.id}"]
  instances       = ["${aws_instance.public-agent-group-1.*.id}", "${aws_instance.public-agent-group-2.*.id}", "${aws_instance.public-agent-group-3.*.id}"]

  listener {
    lb_port           = 80
    instance_port     = 80
    lb_protocol       = "tcp"
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 443
    instance_port     = 443
    lb_protocol       = "tcp"
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:9090/_haproxy_health_check"
    interval = 5
  }

  lifecycle {
    ignore_changes = ["name"]
  }
}

output "Public Agent ELB Address" {
  value = "${aws_elb.public-agent-elb.dns_name}"
}

