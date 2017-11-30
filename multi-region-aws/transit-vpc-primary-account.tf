resource "null_resource" "on-destroy" {
   provisioner "local-exec" {
    when    = "destroy"
    on_failure = "continue"
    command = "aws s3 rb s3://$(aws s3 ls | grep s3://${data.template_file.cluster-name.rendered}-transit-vpc | awk '{print $3}') --force"
    }
}

provider "aws" {
  alias = "central"
  profile = "${var.aws_profile}"
  region = "ca-central-1"
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
