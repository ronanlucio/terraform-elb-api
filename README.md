# terraform-elb-api

## Requirements

### Environment Variables

Create the following environment variables with its appropriate values:

- AWS_ACCESS_KEY_ID=
- AWS_SECRET_ACCESS_KEY=
- TF_VAR_ssh_public_key=

Where AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY refers to AWS account 
to provisioning the underlying infrastructure

TF_VAR_ssh_public_key refers to the SSH public key to be a key pair
in order to access the instance via SSH. 
Note that it relies on having a local SSH key (private and public).

### Softwares

- Terraform >= 1.1.2
- Ansible >= 2.11.7
- Docker >= 20.10.12
