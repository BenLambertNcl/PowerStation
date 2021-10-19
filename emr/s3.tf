resource "aws_s3_bucket" "config" {
  bucket = "data-generator-resources-${random_string.random.result}"
  acl    = "private"
  force_destroy = true
}

resource "random_string" "random" {
  length  = 16
  special = false
  number  = false
  lower   = true
  upper   = false
}