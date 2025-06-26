# SaltStack AWS Terraform Project

Create a Saltstack Dev environment using Terraform on AWS Cloud.
This project demonstrates the integration of SaltStack and Terraform for provisioning and managing infrastructure on AWS.   

By default 3 Ec2 instances will be created:

|Name            | Role           | OS                   |
|----------------|----------------|----------------------|
| Salt-Master    |Salt Master     | Ubuntu               |
| Ubuntu-Salt-Minion-1  |Salt Minion     | Ubuntu               |
| RHEL-Salt-Minion-1  |Salt Minion     | RHEL (Amazon Linux)  |


## Table of Contents

- [SaltStack AWS Terraform Project](#saltstack-aws-terraform-project)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)

## Introduction

This project leverages Terraform to provision AWS resources and SaltStack for configuration management. By combining these powerful tools, we can achieve a highly automated and scalable infrastructure deployment process.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Terraform**: Install Terraform from the [official website](https://www.terraform.io/downloads.html).
- **AWS CLI**: Install the AWS Command Line Interface from the [official website](https://aws.amazon.com/cli/).
- **Git**: Install Git from the [official website](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

Additionally, you need an AWS account and appropriate credentials configured in your environment.

## Installation

1. Create a Directory and a terraform file:

    ```sh
    mkdir tf-saltstack && cd tf-saltstack
    ```
    ```sh
    cat > main.tf <<EOF
    module "saltstack" {
    source  = "prajwalap1701/saltstack/aws"
    version = "3.0.0"
    }
    EOF

    ```

2. Create a keypair for accessing AWS Instances via SSH:
    ```sh
    ssh-keygen -t rsa -b 2048
    ```
    Generates two files (by default in ~/.ssh/):

    id_rsa – your private key (keep this secret!)
    
    id_rsa.pub – your public key (safe to share or copy to servers)

4. Configure your AWS credentials:

    ```sh
    aws configure
    ```

5. Initialize Terraform:

    ```sh
    terraform init
    ```

## Usage

1. Plan the Terraform deployment to see what resources will be created:

    ```sh
    terraform plan
    ```

2. Apply the Terraform configuration to create the AWS resources:

    ```sh
    terraform apply
    ```
    or if you want more/less minions
    ```sh
    terraform apply \
    -var="ubuntu_minion_count=2" \
    -var="rhel_minion_count=3"

    ```
3. Wait for Apply to finish:
    ```
    Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

    Outputs:

    salt_instances = [
    {
        "name" = "Salt-Master"
        "public_ip" = "54.175.13.78"
    },
    {
        "name" = "Ubuntu-Salt-Minion-1"
        "public_ip" = "54.89.255.219"
    },
    {
        "name" = "RHEL-Salt-Minion-1"
        "public_ip" = "54.165.74.231"
    },
    ]
    ```
4. Once the resources are provisioned, ensure that the Salt Master and Minion are correctly set up.
    ```sh
    ssh ubuntu@<salt-master-public-ip>
    ```
    ```sh
    ubuntu@salt-master:~$ sudo salt \* test.ping

    Output:
    ubuntu-minion-1:
        True
    rhel-minion-1:
        True
    minion-localhost:
        True
    ```

