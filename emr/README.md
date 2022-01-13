# EMR
This folder contains terraform to create a cluster to run the generator on.

## Usage
To create the infrastructure, simply run:
```shell
terraform init && terraform apply
```
This will create a basic EMR cluster as an example. Note that at present there is an error when creating the cluster

## Backend
The Terraform state file is by default stored locally

## Configuration
Configuration via variables will be added soon

## Destroy
To destroy the cluster, run:
```shell
terraform init && terraform destroy
```