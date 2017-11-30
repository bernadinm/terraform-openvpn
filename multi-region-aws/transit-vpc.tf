variable "transit_vpc_region" {
 default = "ca-central-1"
}

provider "aws" {
  alias = "central"
  profile = "${var.aws_profile}"
  region = "${var.transit_vpc_region}"
}

resource "aws_vpn_gateway" "vpn_gw_bursting" {
  provider = "aws.bursted-vpc"
  vpc_id = "${aws_vpc.bursted_region.id}"

  tags {
    Name = "${data.template_file.cluster-name.rendered}-bursted-vpc"
    "transitvpc:spoke" = "true"
    owner = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
  }
}

resource "aws_vpn_gateway" "vpn_gw_main" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${data.template_file.cluster-name.rendered}-defaul-vpc"
    "transitvpc:spoke" = "true"
     owner = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
  }
}

resource "aws_vpn_gateway_route_propagation" "bursting" {
  provider = "aws.bursted-vpc"
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_bursting.id}"
  route_table_id = "${aws_vpc.bursted_region.main_route_table_id}"
}

resource "aws_vpn_gateway_route_propagation" "default" {
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_main.id}"
  route_table_id = "${aws_vpc.default.main_route_table_id}"
}

resource "aws_vpn_gateway_attachment" "vpn_attachment_bursting" {
  vpc_id = "${aws_vpc.bursted_region.id}"
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_bursting.id}"
}

resource "aws_vpn_gateway_attachment" "vpn_attachment_default" {
  vpc_id = "${aws_vpc.default.id}"
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_main.id}"
}

resource "aws_cloudformation_stack" "transit-vpc-primary-account" {
  provider = "aws.central"
  name = "${data.template_file.cluster-name.rendered}-transit-vpc-primary-account"
  capabilities = ["CAPABILITY_IAM"]
  parameters {
    KeyName = "${var.key_name}"
    TerminationProtection = "No"
  }

  template_url = "https://s3-us-west-2.amazonaws.com/mbernadin/transit-vpc-primary-account.template"
#  depends_on = ["null_resource.on-destroy"]
}

output "Primary Transit VPC" {
  value = "${aws_cloudformation_stack.transit-vpc-primary-account.outputs}"
}
