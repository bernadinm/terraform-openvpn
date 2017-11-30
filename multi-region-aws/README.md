# Multi-Region Open DC/OS on AWS with Terraform

## Deploying Multi-Region DCOS 

This repository is meant to get the bare minimum of running a multi-region DC/OS cluster. It is not as modifiable as dcos/terraform-dcos so please keep this in mind. 

This repo is configured to deploy on us-east-1 and us-west-2 with a transit vpc sitting in between in ca-central-1.

### Prerequisites

This may be already accepted at Mesosphere's Dev Account. You can follow this instruction below for any other aws root account.

Accept Cisco Cisco Cloud Services Router (CSR) on AWS. This was used to assist with the creation of a Software VPN Router and was launched via Cloudformation through Terraform. You only need to do this once.

1. Navigate to AWS [here](https://aws.amazon.com/marketplace/fulfillment?productId=9f5a4516-a4c3-4cf1-89d4-105d2200230e&ref_=dtl_psb_continue)
2. Click on the Manual Launch Tab
3. Accept the terms on the right and side of the page. 

### Quick Start Deployment of Terraform

Once the license has been accepted, you may proceed with having terraform deploy your entire infrasture below.

```bash
terraform init -from-module github.com/bernadinm/terraform-openvpn//multi-region-aws
terraform apply -var-file desired_cluster_profile
```

### High Level Overview of Architecture

* a Software VPN that lives in ca-central-1 and are leveraging Cisco's AWS solution hub-spoke license. 
* Main DC/OS cluster lives on us-east-1
* Bursting Node lives in us-west-2

### Adding or Remving Remote Nodes or Default Region Nodes

Change the number of remote nodes in the desired cluster profile.

```bash 
$ cat desired_cluster_profile
expiration = "12h"
num_of_masters = "1"
num_of_private_agents = "1"
num_of_public_agents = "1"
aws_region = "us-east-1"
os = "coreos_1465.8.0"
#----Added Below
num_of_remote_private_agents = "5"
```

### Destroy Cluster

1. Navigate to S3 and delete the s3 bucket that is created then run this command below: <owner>-<uniqid>-transit-vpc-pr-vpnconfigs-<id>

2. Destroy the VPC connection on us-west-2 and us-east-1

3. Destroy the VPC Private Gateway on us-west-2 and us-east-1

4. Destroy the VPC Customer Gateway on us-west-2 and us-east-1

5. Destroy cloudformation template
```bash
terraform destroy -var-file desired_cluster_profile
```
