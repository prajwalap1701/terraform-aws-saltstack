# SaltStack AWS Terraform Project

Create a Saltstack environment using Terraform on AWS Cloud.
This project demonstrates the integration of SaltStack and Terraform for provisioning and managing infrastructure on AWS.   
The repository contains configurations and scripts to automate the deployment of AWS resources and configure them using SaltStack.

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

1. Clone the repository:

    ```sh
    git clone https://github.com/prajwalap1701/terraform-aws-saltstack.git
    cd terraform-aws-saltstack
    ```

2. Create a keypair for accessing AWS Instances via SSH:
   ```sh
   mkdir keys
    ```
    ```sh
    ssh-keygen -t rsa -b 2048 -f ./keys/aws-key
    ```

4. Initialize Terraform:

    ```sh
    terraform init
    ```

5. Configure your AWS credentials:

    ```sh
    aws configure
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
    terraform apply -var="minion_count=2"
    ```

3. Once the resources are provisioned, ensure that the Salt Master and Minion are correctly set up.
    ```sh
    sudo salt '*' test.ping
    ```
    Output:
    ```
    minion-0:
        True
    minion-1:
        True
    minion-2:
        True
    ```

4. Run Salt states to apply the configurations:

    ```sh
    sudo salt '*' state.apply
    ```
