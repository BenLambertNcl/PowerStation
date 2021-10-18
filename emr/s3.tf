resource "aws_s3_bucket" "config" {
  bucket = "data-generator-resources-${timestamp()}"
  acl    = "private"
}
