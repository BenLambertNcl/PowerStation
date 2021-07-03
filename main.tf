provider "aws" {
  region = "eu-west-2"
}

resource "aws_emr_cluster" "cluster" {
  name = "data-generator-cluster"
  release_label = "emr-6.3.0"

  applications = ["spark"]

  termination_protection = false
  keep_job_flow_alive_when_no_steps = true

  master_instance_group {
    instance_type = "m4.large"
  }

  core_instance_group {
    instance_type = "c4.large"
    instance_count = 1

    ebs_config {
      size = "40"
      type = "gp2"
      volumes_per_instance = 1
    }

    ebs_root_volume_size = 100
  }

  service_role = data.aws_iam_role.service_role.arn
}


data "aws_iam_role" "service_role" {
  name = "EMR_DefaultRole"
}
