provider "aws" {
  region = "ap-southeast-1"
  default_tags {
      tags = {
          awsApplication = "arn:aws:resource-groups:ap-southeast-1:373984650075:group/mtls_apigw_pem_cert/048ld030gm5z57pvwx0unymq1l"
      }
  }
}

# Create S3 bucket for truststore
resource "aws_s3_bucket" "truststore" {
  bucket = "my-mtls-truststore-${random_string.suffix.result}"
}

# Generate random suffix for bucket name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "truststore" {
  bucket = aws_s3_bucket.truststore.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Upload truststore to S3
resource "aws_s3_object" "truststore" {
  bucket = aws_s3_bucket.truststore.id
  key    = "truststore.pem"
  source = "certs/truststore.pem"  # Make sure this file exists
}

# Create HTTP API
resource "aws_apigatewayv2_api" "mtls_api" {
  name          = "mtls-api"
  protocol_type = "HTTP"
  
  disable_execute_api_endpoint = false
}

# Add test routes with Lambda proxy integration
resource "aws_apigatewayv2_integration" "mock" {
  api_id           = aws_apigatewayv2_api.mtls_api.id
  integration_type = "HTTP_PROXY"
  integration_method = "GET"
  integration_uri  = "https://httpbin.org/anything"
}

# Create test routes
resource "aws_apigatewayv2_route" "get_test" {
  api_id    = aws_apigatewayv2_api.mtls_api.id
  route_key = "GET /test"
  target    = "integrations/${aws_apigatewayv2_integration.mock.id}"
}

resource "aws_apigatewayv2_route" "post_test" {
  api_id    = aws_apigatewayv2_api.mtls_api.id
  route_key = "POST /test"
  target    = "integrations/${aws_apigatewayv2_integration.mock.id}"
}

# Create custom domain name with mTLS
resource "aws_apigatewayv2_domain_name" "mtls_domain" {
  domain_name = "api.freedevnews.com"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  mutual_tls_authentication {
    truststore_uri     = "s3://${aws_s3_bucket.truststore.id}/${aws_s3_object.truststore.key}"
    truststore_version = aws_s3_object.truststore.version_id
  }
}

# Create ACM certificate
resource "aws_acm_certificate" "api_cert" {
  domain_name       = "api.freedevnews.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Add output for default endpoint
output "default_api_endpoint" {
  value = aws_apigatewayv2_api.mtls_api.api_endpoint
}

# Create stage
resource "aws_apigatewayv2_stage" "mtls_stage" {
  api_id      = aws_apigatewayv2_api.mtls_api.id
  name        = "prod"
  auto_deploy = true
}

# Create API mapping
resource "aws_apigatewayv2_api_mapping" "mtls" {
  api_id      = aws_apigatewayv2_api.mtls_api.id
  domain_name = aws_apigatewayv2_domain_name.mtls_domain.domain_name
  stage       = aws_apigatewayv2_stage.mtls_stage.name
}

# Output values
output "api_endpoint" {
  value = aws_apigatewayv2_domain_name.mtls_domain.domain_name
}