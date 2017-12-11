# Multi-Region Open DC/OS on AWS with Terraform

## Deploying Multi-Region DCOS 

This repository is meant to get the bare minimum of running a multi-region DC/OS cluster. It is not as modifiable as dcos/terraform-dcos so please keep this in mind. 

This repo is configured to deploy on us-east-1 and us-west-2 with an AWS VPC Peering connection across regions.

Requirements
------------

-	[Terraform](https://www.terraform.io/downloads.html) 0.10.x
-	[Go](https://golang.org/doc/install) 1.9 (to build the provider plugin)

Building The Provider
---------------------

Clone repository to: `$GOPATH/src/github.com/terraform-providers/terraform-provider-aws`

```sh
mkdir -p $GOPATH/src/github.com/terraform-providers; cd $GOPATH/src/github.com/terraform-providers
git clone -b inter-region-vpc-peer git@github.com:kl4w/terraform-provider-aws.git
cd $GOPATH/src/github.com/terraform-providers/terraform-provider-aws
make build
```

```bash
terraform init -from-module github.com/bernadinm/terraform-openvpn//multi-region-aws
terraform apply -var-file desired_cluster_profile
```

### High Level Overview of Architecture

* a VPC Peering connection that connects us-east-1 and us-west-2 
* Main DC/OS cluster lives on us-east-1
* Bursting Node lives in us-west-2

### Adding or Remving Remote Nodes or Default Region Nodes

Change the number of remote nodes in the desired cluster profile.

```bash 
$ cat desired_cluster_profile
dcos_version = "1.11-dev"
expiration = "12h"
num_of_masters = "1"
num_of_private_agents = "1"
num_of_public_agents = "1"
aws_region = "us-east-1"
aws_remote_region = "us-west-2"
aws_remote_agent_az = "c"
#----Added Below
num_of_remote_private_agents = "5"
```

```bash
terraform apply -var-file desired_cluster_profile
```
### Destroy Cluster


1. Destroy terraform with this command below.
```bash
terraform destroy -var-file desired_cluster_profile
```
2. Remove the AWS inter-region aws provisioner to revert back to default.
```bash
rm -fr $GOPATH/bin/terraform-provider-aws
```


Note: No major enhancements should be expected with this repo. It is meant for demo and testing purposes only.
