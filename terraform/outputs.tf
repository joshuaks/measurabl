output api_endpoint {
  description = "api endpoint which gets counter value and updates"
  value = aws_apigatewayv2_api.endpoint.api_endpoint
}

output website_endpoint {
  description = "the website which displays the counter value"
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}
