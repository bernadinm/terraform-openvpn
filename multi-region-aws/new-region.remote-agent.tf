variable "num_of_remote_private_agents" {
  default = "1"
}

variable "aws_second_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

provider "aws" {
  alias = "bursted-vpc"
  profile = "${var.aws_profile}"
  region = "${var.aws_second_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "bursted_region" {
  provider = "aws.bursted-vpc"
  cidr_block = "10.128.0.0/16"
  #enable_dns_hostnames = "true"

tags {
   Name = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "bursted_region" {
  provider = "aws.bursted-vpc"
  vpc_id = "${aws_vpc.bursted_region.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "second_internet_access" {
  provider = "aws.bursted-vpc"
   route_table_id         = "${aws_vpc.bursted_region.main_route_table_id}"
   destination_cidr_block = "0.0.0.0/0"
   gateway_id             = "${aws_internet_gateway.bursted_region.id}"
}

# Create a subnet to launch public nodes into
resource "aws_subnet" "second_public" {
  provider = "aws.bursted-vpc"
  vpc_id                  = "${aws_vpc.bursted_region.id}"
  cidr_block              = "10.128.0.0/22"
  map_public_ip_on_launch = true
}

# Create a subnet to launch slave private node into
resource "aws_subnet" "second_private" {
  provider = "aws.bursted-vpc"
  vpc_id                  = "${aws_vpc.bursted_region.id}"
  cidr_block              = "10.128.4.0/22"
  map_public_ip_on_launch = true
}

# A security group that allows all port access to internal vpc
resource "aws_security_group" "second_any_access_internal" {
  provider = "aws.bursted-vpc"
  name        = "cluster-security-group"
  description = "Manage all ports cluster level"
  vpc_id      = "${aws_vpc.bursted_region.id}"

 # full access internally
 ingress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${aws_vpc.bursted_region.cidr_block}"]
  }

 # full access internally
 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${aws_vpc.bursted_region.cidr_block}"]
  }
}

resource "aws_security_group" "second_admin" {
  provider = "aws.bursted-vpc"
  name        = "admin-security-group"
  description = "Administrators can manage their machines"
  vpc_id      = "${aws_vpc.bursted_region.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  # http access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  # httpS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A security group for private slave so it is accessible internally
resource "aws_security_group" "second_private_slave" {
  provider = "aws.bursted-vpc"
  name        = "private-slave-security-group"
  description = "security group for slave private"
  vpc_id      = "${aws_vpc.bursted_region.id}"

  # full access internally
  ingress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["${aws_vpc.default.cidr_block}"]
   }

  # full access internally
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["${aws_vpc.default.cidr_block}"]
   }
}

# Create a subnet to launch slave private node into
resource "aws_subnet" "remote_second_private" {
  provider = "aws.bursted-vpc"
  vpc_id                  = "${aws_vpc.bursted_region.id}"
  cidr_block              = "10.128.8.0/22"
  map_public_ip_on_launch = true
}

resource "aws_instance" "remote_agent" {
  provider = "aws.bursted-vpc"
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${module.aws-tested-oses.user}"

    # The connection will use the local SSH agent for authentication.
  }

  root_block_device {
    volume_size = "${var.instance_disk_size}"
  }

  count = "${var.num_of_remote_private_agents}"
  instance_type = "${var.aws_agent_instance_type}"

  tags {
   owner = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
   expiration = "${var.expiration}"
   Name =  "${data.template_file.cluster-name.rendered}-remotepvtagt-${count.index + 1}"
   cluster = "${data.template_file.cluster-name.rendered}"
  }
  # Lookup the correct AMI based on the region
  # we specified
  ami = "ami-82bd41fa" # coreos_1235.5.0_us-west-2

  # The name of our SSH keypair we created above.
  key_name = "${var.key_name}"

  # Our Security group to allow http and SSH access
  vpc_security_group_ids = ["${aws_security_group.second_private_slave.id}","${aws_security_group.second_admin.id}","${aws_security_group.second_any_access_internal.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.second_private.id}"

  # OS init script
  provisioner "file" {
   content = "${module.aws-tested-oses.os-setup}"
   destination = "/tmp/os-setup.sh"
   }

 # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
    provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/os-setup.sh",
      "sudo bash /tmp/os-setup.sh",
    ]
  }

  lifecycle {
    ignore_changes = ["tags.Name"]
  }
}

# Create DCOS Mesos Agent Scripts to execute
module "dcos-remote-mesos-agent" {
  source = "git@github.com:amitaekbote/terraform-dcos-enterprise//tf_dcos_core?ref=addnode"
  bootstrap_private_ip = "${aws_instance.bootstrap.private_ip}"
  dcos_install_mode    = "${var.state}"
  dcos_version         = "${var.dcos_version}"
  role                 = "dcos-mesos-agent"
}

# Execute generated script on agent
resource "null_resource" "remote_agent" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${null_resource.bootstrap.id}"
    current_ec2_instance_id = "${aws_instance.remote_agent.*.id[count.index]}"
  }
  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(aws_instance.remote_agent.*.public_ip, count.index)}"
    user = "${module.aws-tested-oses.user}"
  }

  count = "${var.num_of_remote_private_agents}"

  # Generate and upload Agent script to node
  provisioner "file" {
    content     = "${module.dcos-remote-mesos-agent.script}"
    destination = "run.sh"
  }

  # Wait for bootstrapnode to be ready
  provisioner "remote-exec" {
    inline = [
     "until $(curl --output /dev/null --silent --head --fail http://${aws_instance.bootstrap.private_ip}/dcos_install.sh); do printf 'waiting for bootstrap node to serve...'; sleep 20; done"
    ]
  }

  # Install Slave Node
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x run.sh",
      "sudo ./run.sh",
    ]
  }
}

output "Remote Private Agent Public IP Address" {
  value = ["${aws_instance.remote_agent.*.public_ip}"]
}
