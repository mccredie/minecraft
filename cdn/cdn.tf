
variable "certificate_arn" {
  type = string
  description = "arn of the ACM certificate for the domain. Must be in us-east-1"
}

variable "domain_name" {
  type = string
  description = "domain name used as a cloudfront alias. Should match certificate arn."
}

variable "service_path" {
  type = string
  description = "path to prefix service requests"
}

variable "hosted_zone_id" {
  type = string
  description = "hosted zone where dns record for cloudfront is created"
}

variable "portal_access_identity" {
  description = "Origin Access Identity path for distribution S3 access"
}

variable "portal_domain" {
  description = "domain name of the hosting bucket"
}

variable "service_stack_name" {
  description = "Name of the cloudformation stack that contains the service"
}

data "aws_cloudformation_stack" "service_stack" {
  name = var.service_stack_name
}

resource "aws_route53_record" "dns" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name = aws_cloudfront_distribution.hosting_distribution.domain_name
    zone_id = aws_cloudfront_distribution.hosting_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "hosting_distribution" {
    aliases                        = [
        var.domain_name,
    ]
    enabled = true
    is_ipv6_enabled = true

    default_root_object            = "index.html"
    http_version                   = "http2"

    price_class                    = "PriceClass_100"

    default_cache_behavior {
        allowed_methods        = [
            "GET",
            "HEAD",
        ]
        cached_methods         = [
            "GET",
            "HEAD",
        ]
        compress               = false
        default_ttl            = 86400
        max_ttl                = 31536000
        min_ttl                = 0
        smooth_streaming       = false
        target_origin_id       = "hosting-bucket"
        viewer_protocol_policy = "redirect-to-https"

        forwarded_values {
            headers                 = []
            query_string            = false
            query_string_cache_keys = []

            cookies {
                forward           = "none"
                whitelisted_names = []
            }
        }
    }

    ordered_cache_behavior {
        allowed_methods        = [
            "DELETE",
            "GET",
            "HEAD",
            "OPTIONS",
            "PATCH",
            "POST",
            "PUT",
        ]
        cached_methods         = [
            "GET",
            "HEAD",
        ]
        compress               = false
        default_ttl            = 0
        max_ttl                = 0
        min_ttl                = 0
        path_pattern           = "api/*"
        smooth_streaming       = false
        target_origin_id       = "service-endpoint"
        trusted_signers        = []
        viewer_protocol_policy = "redirect-to-https"

        forwarded_values {
            headers                 = [
                "Accept",
                "Authorization",
                "Origin",
                "Referer",
                "Access-Control-Request-Headers",
                "Access-Control-Request-Method",
                "Access-Control-Allow-Origin",
            ]
            query_string            = false
            query_string_cache_keys = []

            cookies {
                forward           = "none"
                whitelisted_names = []
            }
        }
    }
    ordered_cache_behavior {
        allowed_methods        = [
            "DELETE",
            "GET",
            "HEAD",
            "OPTIONS",
            "PATCH",
            "POST",
            "PUT",
        ]
        cached_methods         = [
            "GET",
            "HEAD",
        ]
        compress               = false
        default_ttl            = 0
        max_ttl                = 0
        min_ttl                = 0
        path_pattern           = "api"
        smooth_streaming       = false
        target_origin_id       = "service-endpoint"
        trusted_signers        = []
        viewer_protocol_policy = "redirect-to-https"

        forwarded_values {
            headers                 = [
                "Accept",
                "Authorization",
                "Origin",
                "Referer",
                "Access-Control-Request-Headers",
                "Access-Control-Request-Method",
                "Access-Control-Allow-Origin",
            ]
            query_string            = false
            query_string_cache_keys = []

            cookies {
                forward           = "none"
                whitelisted_names = []
            }
        }
    }

    origin {
        domain_name = data.aws_cloudformation_stack.service_stack.outputs.ServiceDomain

        origin_id   = "service-endpoint"
        origin_path = var.service_path

        custom_origin_config {
            http_port                = 80
            https_port               = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy   = "https-only"
            origin_read_timeout      = 30
            origin_ssl_protocols     = [
                "TLSv1.1",
                "TLSv1.2",
            ]
        }
    }

    origin {
        domain_name = var.portal_domain
        origin_id   = "hosting-bucket"

        s3_origin_config {
            origin_access_identity = var.portal_access_identity
        }
    }

    restrictions {
        geo_restriction {
            locations        = []
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn            = var.certificate_arn
        cloudfront_default_certificate = false
        minimum_protocol_version       = "TLSv1.1_2016"
        ssl_support_method             = "sni-only"
    }
}


output "distribution_id" {
  value = aws_cloudfront_distribution.hosting_distribution.id
}
