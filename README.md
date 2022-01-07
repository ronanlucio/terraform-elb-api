# terraform-elb-api

## Overview

- App source files are stored on **app** folder
- Terraform files are stored on **terraform** folder
- Ansible files are stored on **ansible** folder
- Terraform provisions the underlying infrastructure
- Ansible builds App's docker image, pushes it to AWS ECR, and deploy it to EC2 instance

### Usage

Executing a **terraform apply** command (1) creates the underlying infrastructure,
(2) build a docker container with API, push it to AWS ECR, and (3) deploy the container
image to the provisioned EC2 instance.

```
$ sudo
# cd terraform
# ssh-agent bash
# ssh-add /path/to/your/private/key
# terraform plan
# terraform apply
```

NOTES:

1. You need to run **terraform apply** with root privileges in order to ansible install local system dependencies
2. You'll be prompted for the app_version parameter, so you can provide any version value like "1.0.0"
3. At the end of terraform execution, it will print the load balancer DNS address to be accessed via HTTP.

## Requirements

### AWS Account

1. AWS Account
2. AWS User with permissions for Terraform to create the underlying infrastructure
    - Key Pair
    - Security Groups
    - EC2
    - ALB
    - Target Groups
3. A second AWS User for the API to list, attach, and detach instances from Load Balancer
    - List instances attached to ALB
    - Attach instance to ALB
    - Detach instance from ALB

### Environment Variables

Create the following environment variables with its appropriate values:

- TF_VAR_ssh_public_key=
- TF_VAR_AWS_ACCESS_KEY_ID=
- TF_VAR_AWS_SECRET_ACCESS_KEY=
- TF_VAR_APP_AWS_ACCESS_KEY_ID=
- TF_VAR_APP_AWS_SECRET_ACCESS_KEY=
- APP_AWS_REGION

NOTES: 

1. AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY refers to AWS Account to be used by Terraform to provision the underlying infrastructure
2. TF_VAR_APP_AWS_ACCESS_KEY_ID and TF_VAR_APP_AWS_SECRET_ACCESS_KEY refers to AWS Account to be used by the API to list, attach, and detach instances to/from ALB
3. TF_VAR_ssh_public_key refers to the SSH public key to be a key pair in order to access the instance via SSH. 
4. Note that it relies on having a local SSH key (private and public).

### Softwares

- AWS CLI >= 2.4.1
- Terraform >= 1.1.2
- Ansible >= 2.11.7
- Docker >= 20.10.12
- Python >= 3.8
- Python Pip3 >= 20.0.2
- Python Boto3

## Running Individual Tests

### Build Container Image

To locally build and test the docker container, you first need to set the following environment variables

```
export APP_AWS_ACCESS_KEY_ID=
export APP_AWS_SECRET_ACCESS_KEY=
export APP_AWS_REGION=
```

So you can build the container image

```
cd app
docker build --no-cache -t elb-api:0.0.1 --build-arg APP_AWS_ACCESS_KEY_ID --build-arg APP_AWS_SECRET_ACCESS_KEY --build-arg APP_AWS_REGION .
```

### Running Container Image

```
docker run --rm -p "80:88080" elb-api:0.0.1
```

## Ansible

```
export INSTANCE_IP="54.89.189.38"
export ECR_REPOSITORY="993359121485.dkr.ecr.us-east-1.amazonaws.com/elb_api"
export APP_VERSION="0.0.2"
export APP_AWS_REGION="us-east-1"

ansible-playbook build-elb-api.yaml \
    -e 'ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"'     
    --extra-vars "aws_region=${APP_AWS_REGION} ecr_repository_url=${ECR_REPOSITORY} app_version=${APP_VERSION}" \
    -i localhost,

ansible-playbook deploy-elb-api.yaml \
    -e "ansible_user=ubuntu" \
    --extra-vars "aws_region=${APP_AWS_REGION} ecr_repository_url=${ECR_REPOSITORY} app_version=${APP_VERSION}" \
    -i ${INSTANCE_IP},
```
