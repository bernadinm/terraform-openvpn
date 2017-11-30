# Multi-Region Open DC/OS on AWS with Terraform

## Deploying Multi-Region DCOS 

This repository is meant to get the bare minimum of running a multi-region DC/OS cluster. It is not as modifiable as dcos/terraform-dcos so please keep this in mind. 

This repo is configured to deploy on us-east-1 and us-west-2 with a transit vpc sitting in between in ca-central-1.

### Prerequisites

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

### Destroy Cluster

You can shutdown/destroy all resources from your environment by running this command below

```bash
terraform destroy -var-file desired_cluster_profile
```
