
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for distribution S3 access"
}

resource "aws_s3_bucket" "hosting" {
    acl                         = "private"
    request_payer               = "BucketOwner"
    force_destroy               = false

    versioning {
        enabled    = false
        mfa_delete = false
    }

    tags                        = {}
}

resource "aws_s3_bucket_policy" "hosting" {
    bucket = aws_s3_bucket.hosting.id
    policy = jsonencode(
        {
            Id        = "PolicyForCloudFrontPrivateContent"
            Statement = [
                {
                    Action    = "s3:GetObject"
                    Resource  = "${aws_s3_bucket.hosting.arn}/*"
                    Effect    = "Allow"
                    Principal = {
                       AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
                    }
                    Sid       = "1"
                },
            ]
            Version = "2008-10-17"
        }
    )
}

output "domain" {
  value = aws_s3_bucket.hosting.bucket_domain_name
}

output "access_identity" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
}

