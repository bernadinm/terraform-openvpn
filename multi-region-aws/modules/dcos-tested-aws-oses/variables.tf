variable "aws_default_os_user" {
 type = "map"
 default = {
 coreos = "core"
 centos = "centos"
 ubuntu = "ubuntu"
 rhel   = "ec2-user"
 }
}

variable "aws_ami" {
 type = "map"
 default = {
 coreos_835.13.0_eu-west-1 = "ami-4b18aa38"
 coreos_1235.9.0_eu-west-1 = "ami-188dd67e"
 coreos_1465.8.0_eu-west-1 = "ami-1a589463"
 centos_7.2_ap-south-1     = "ami-95cda6fa"
 centos_7.2_eu-west-2      = "ami-bb373ddf"
 centos_7.2_eu-west-1      = "ami-7abd0209"
 centos_7.2_ap-northeast-2 = "ami-c74789a9"
 centos_7.2_ap-northeast-1 = "ami-eec1c380"
 centos_7.2_sa-east-1      = "ami-26b93b4a"
 centos_7.2_ca-central-1   = "ami-af62d0cb"
 centos_7.2_ap-southeast-1 = "ami-f068a193"
 centos_7.2_ap-southeast-2 = "ami-fedafc9d"
 centos_7.2_eu-central-1   = "ami-9bf712f4"
 centos_7.2_us-east-1      = "ami-6d1c2007"
 centos_7.2_us-east-2      = "ami-6a2d760f"
 centos_7.2_us-west-1      = "ami-af4333cf"
 centos_7.2_us-west-2      = "ami-d2c924b2"
 centos_7.3_us-west-2      = "ami-f4533694"
 coreos_835.13.0_us-west-2 = "ami-4f00e32f"
 coreos_1235.9.0_us-west-2 = "ami-4c49f22c"
 coreos_1465.8.0_us-west-2 = "ami-82bd41fa" # HVM
 coreos_1465.8.0_us-east-1 = "ami-e2d33d98" # HVM
 rhel_7.3_us-west-2        = "ami-b55a51cc"
 }
}
