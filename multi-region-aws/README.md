# Multi-Region Enterprise DC/OS on AWS with Terraform

Requirements
------------

-	[Terraform](https://www.terraform.io/downloads.html) 0.10.x

## Deploying Multi-Region DCOS 

This repository is meant to get the bare minimum of running a multi-region DC/OS cluster. It is not as modifiable as dcos/terraform-dcos so please keep this in mind. 

This repo is configured to deploy on us-east-1 and us-west-2 with an AWS VPC Peering connection across regions.


## Terraform Quick Start

```bash
mkdir terraform-demo && cd terraform-demo
terraform init -from-module github.com/bernadinm/terraform-openvpn//multi-region-aws
cp desired_cluster_profile.tfvars.example desired_cluster_profile.tfvars
# Add License Key in desired_cluster_profile.tfvars, your aws_profile, other related ssh keys needed
terraform apply -var-file desired_cluster_profile.tfvars
```

### High Level Overview of Architecture

* a VPC Peering connection that connects us-east-1 and us-west-2 
* Main DC/OS cluster lives on us-east-1
* Bursting Node lives in us-west-2

## Configure AWS SSH Keys

You can either upload your existing SSH keys or use an SSH key already created on AWS.

* **Upload existing key**:
    To upload your own key not stored on AWS, read [how to import your own key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws)

* **Create new key**:
    To create a new key via AWS, read [how to create a key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

When complete, retrieve the key pair name and ensure that it matches the `ssh_key_name` in your [desired_cluster_profile.tfvars](/aws/desired_cluster_profile.tfvars.example).

**Note**: The [desired_cluster_profile.tfvars](/aws/desired_cluster_profile.tfvars.example) always takes precedence over the [variables.tf](/aws/variables.tf) and is **best practice** for any variable changes that are specific to your cluster.

When you have your key available, you can use ssh-add.

```bash
ssh-add ~/.ssh/path_to_you_key.pem
```

**Note**: When using an SSH agent it is best to add the command above to your `~/.bash_profile`. Next time your terminal gets reopened, it will reload your keys automatically.

## Configure IAM AWS Keys

You will need your AWS `aws_access_key_id` and `aws_secret_access_key`. If you don't have one yet, you can get them from the [AWS access keys documentation](
http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).

When you get them, you can install it in your home directory. The default location is `$HOME/.aws/credentials` on Linux and macOS, or `"%USERPROFILE%\.aws\credentials"` for Windows users.

Here is an example of the output when you're done:

```bash
$ cat ~/.aws/credentials
[default]
aws_access_key_id = ACHEHS71DG712w7EXAMPLE
aws_secret_access_key = /R8SHF+SHFJaerSKE83awf4ASyrF83sa471DHSEXAMPLE
```

**Note**: `[default]` is the name of the `aws_profile`. You may select a different profile to use in Terraform by adding it to your `desired_cluster_profile.tfvars` as `aws_profile = "<INSERT_CREDENTIAL_PROFILE_NAME_HERE>"`.

## Deploy DC/OS

### Deploying with Custom Configuration

The default variables are tracked in the [variables.tf](/aws/variables.tf) file. Since this file can be overwritten during updates when you may run `terraform get --update` when you fetch new releases of DC/OS to upgrade to, it's best to use the [desired_cluster_profile.tfvars](/aws/desired_cluster_profile.tfvars.example) and set your custom Terraform and DC/OS flags there. This way you can keep track of a single file that you can use manage the lifecycle of your cluster.

#### Supported Operating Systems

Here is the [list of operating systems supported](/aws/modules/dcos-tested-aws-oses/platform/cloud/aws).

#### Supported DC/OS Versions

Here is the [list of DC/OS versions supported](https://github.com/dcos/tf_dcos_core/tree/master/dcos-versions).

**Note**: Master DC/OS version is not meant for production use. It is only for CI/CD testing.

To apply the configuration file, you can use this command below.

```bash
terraform apply -var-file desired_cluster_profile.tfvars
```

### Adding or Remving Remote Nodes or Default Region Nodes

Change the number of remote nodes in the desired cluster profile.

```bash 
$ cat desired_cluster_profile
dcos_version = "1.11.2"
os = "centos_7.3"
expiration = "3h"
num_of_masters = "1"
aws_region = "us-east-1"
# ---- Private Agents Zone / Instance
aws_group_1_private_agent_az = "a"
aws_group_2_private_agent_az = "b"
aws_group_3_private_agent_az = "c"
num_of_private_agent_group_1 = "1"
num_of_private_agent_group_2 = "1"
num_of_private_agent_group_3 = "1"
# ---- Public Agents Zone / Instance
aws_group_1_public_agent_az = "a"
aws_group_2_public_agent_az = "b"
aws_group_3_public_agent_az = "c"
num_of_public_agent_group_1 = "1"
num_of_public_agent_group_2 = "1"
num_of_public_agent_group_3 = "1"
# ----- Remote Region Below
aws_remote_region = "us-west-2"
aws_remote_agent_group_1_az = "a"
aws_remote_agent_group_2_az = "b"
aws_remote_agent_group_3_az = "c"
num_of_remote_private_agents_group_1 = "1"
num_of_remote_private_agents_group_2 = "1"
num_of_remote_private_agents_group_3 = "1"
dcos_security = <<EOF
permissive
license_key_contents: <INSERT_LICENSE_HERE>
EOF
```

```bash
terraform apply -var-file desired_cluster_profile.tfvars
```
### Destroy Cluster


1. Destroy terraform with this command below.
```bash
terraform destroy -var-file desired_cluster_profile.tfvars
```

Note: No major enhancements should be expected with this repo. It is meant for demo and testing purposes only.
