# s3 bucket for alb acces/error log storage
resource "aws_s3_bucket" "alb_log_bucket" {
  bucket        = "my-alb-logs-bucket-4712"
  force_destroy = true

  tags = {
    Name = "ALB Bucket Logs"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.alb_log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_bucket_ownership" {
  bucket = aws_s3_bucket.alb_log_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "alb_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.alb_bucket_ownership]

  bucket = aws_s3_bucket.alb_log_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "alb_bucket_policy" {
  bucket = aws_s3_bucket.alb_log_bucket.id
  policy = data.aws_iam_policy_document.alb_logs_resource_policy.json
}


data "aws_iam_policy_document" "alb_logs_resource_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.elb_principal_value]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.alb_log_bucket.arn}/*",
      aws_s3_bucket.alb_log_bucket.arn
    ]
  }
}


