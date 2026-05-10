provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket = "sctp-ce12-tfstate-bucket" # Change this
    key    = "madhu-activity3.l2-s3"    # Change this
    region = "ap-southeast-1"
  }
}

resource "aws_s3_bucket" "s3_tf" {
  bucket_prefix = "s3-tf-madhu" # Set your bucket name here
}

resource "aws_s3_bucket_public_access_block" "s3_tf" {
  bucket                  = aws_s3_bucket.s3_tf.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_tf" {
  bucket = aws_s3_bucket.s3_tf.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_tf" {
  bucket = aws_s3_bucket.s3_tf.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "s3-log-bucket"
}

resource "aws_s3_bucket_logging" "s3_tf" {
  bucket        = aws_s3_bucket.s3_tf.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_tf" {
  bucket = aws_s3_bucket.s3_tf.id

  rule {
    id     = "cleanup"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}