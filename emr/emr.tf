module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "data-generator-vpc"
  cidr = "10.0.0.0/16"

  enable_nat_gateway = true
  single_nat_gateway = true

  azs             = ["eu-west-2a"]
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]


  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    },
  }

  depends_on = [module.vpc]
}

module "emr_cluster" {
  source = "cloudposse/emr-cluster/aws"

  name                                = "Data Generator"
  applications                        = ["Spark"]
  release_label                       = "emr-6.4.0"
  core_instance_group_ebs_size        = 8
  core_instance_group_instance_type   = "m5.xlarge"
  master_instance_group_ebs_size      = 8
  master_instance_group_instance_type = "m5.xlarge"
  region                              = "eu-west-2"
  subnet_id                           = module.vpc.private_subnets[0]
  vpc_id                              = module.vpc.vpc_id

  bootstrap_action = [
    {
      name = "bootstrap"
      path = "s3://${aws_s3_bucket.config.bucket}/setup.sh"
      args = [aws_s3_bucket.config.bucket]
    }
  ]

log_uri = "s3://${aws_s3_bucket.config.bucket}/logs"

  depends_on = [module.vpc_endpoints]
}