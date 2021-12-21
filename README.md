# terraform-elb-api

## Requirements

### AWS Account

1. AWS Account
2. AWS User with permissions for using with Terraform to create the underlying infrastructure
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

- AWS_ACCESS_KEY_ID=
- AWS_SECRET_ACCESS_KEY=
- TF_VAR_ssh_public_key=
- TF_VAR_app_aws_access_key_id=
- TF_VAR_app_aws_secret_access_key=

NOTES: 

1. AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY refers to AWS Account to be used by Terraform
2. TF_VAR_app_aws_access_key_id and TF_VAR_app_aws_secret_access_key refers to AWS Account to be used by the API
3. TF_VAR_ssh_public_key refers to the SSH public key to be a key pair in order to access the instance via SSH. 
4. Note that it relies on having a local SSH key (private and public).

### Softwares

- Terraform >= 1.1.2
- Ansible >= 2.11.7
- Docker >= 20.10.12
- Python >= 3.8
- Python Boto3
