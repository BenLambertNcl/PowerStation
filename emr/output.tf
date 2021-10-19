output "cluster_id" {
  value = module.emr_cluster.cluster_id
}

output "bucket_name" {
  value = aws_s3_bucket.config.bucket
}
