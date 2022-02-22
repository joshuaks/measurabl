locals {
  db_table_hash_key = "webpage"
}



# #################################################
# DYNAMODB - WEB PAGE VIEW COUNTER DB
# #################################################
resource aws_dynamodb_table _ {
  name           = var.default_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = local.db_table_hash_key

  attribute {
    name = local.db_table_hash_key
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}


resource aws_dynamodb_table_item _ {
  table_name = aws_dynamodb_table._.name
  hash_key   = aws_dynamodb_table._.hash_key

    item = <<ITEM
{
  "webpage": {"S": "${var.db_webpage_name}"},
  "view_count": {"N": "0"}
}
ITEM

  lifecycle {
    ignore_changes = [
      item # otherwise count will be reset on every apply
    ]
  }
}




# #################################################
# LAMBDA - fetches current web page hit value and updates the value
# #################################################
data archive_file lambda { 
  type        = "zip"
  source_file = "support/lambda/update_webpage_counter.js"
  output_path = "/tmp/lambda.zip"
}


resource aws_lambda_function _ {
  filename         = data.archive_file.lambda.output_path
  function_name    = "update_webpage_counter"
  role             = var.lambda_role_arn
  handler          = "update_webpage_counter.handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)
  architectures    = [var.lambda_architecture] # cheaper
  description      = "this function updates the webpage view counter"

  environment {
    variables    = {
      TABLE_NAME = aws_dynamodb_table._.name
      WEB_PAGE   = var.db_webpage_name
    }
  }
}




# #################################################
# GATEWAY API - sits in front of the lambda so it can be trigged on-demand
# #################################################
resource aws_apigatewayv2_api _ {
  protocol_type   = "HTTP"
  name            = var.default_name
  description     = "points to aws lambda which reports and updates a web page view counter"
  target          = aws_lambda_function._.arn
  cors_configuration {
    allow_origins = ["http://*"]
    allow_methods = ["GET"]
  }
}


resource aws_apigatewayv2_integration _ {
  api_id                 = aws_apigatewayv2_api._.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  description            = "integrates with the lamda web page counter logic"
  integration_method     = "POST" # this is unrelated to web calls
  integration_uri        = aws_lambda_function._.invoke_arn
  payload_format_version = "2.0"
}


resource aws_lambda_permission _ {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function._.function_name
  principal     = "apigateway.amazonaws.com"
}


resource aws_apigatewayv2_route _ {
  api_id    = aws_apigatewayv2_api._.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration._.id}"
}




# #################################################
# S3 BUCKET - hosts the static site
# #################################################
resource aws_s3_bucket _ {
  bucket_prefix = lower(var.default_name)
}


resource aws_s3_bucket_acl _ {
  bucket = aws_s3_bucket._.id
  acl    = "private"
}


resource aws_s3_account_public_access_block _ {
  # must be disabled to serve the static site
  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
}


resource aws_s3_bucket_versioning _ {
  bucket = aws_s3_bucket._.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource aws_s3_bucket_policy _ {
  bucket = aws_s3_bucket._.id
  policy = data.aws_iam_policy_document._.json
}


data aws_iam_policy_document _ {
  version = "2012-10-17"
  statement {
    effect         = "Allow"
    sid            = "PublicReadGetObject"
    principals {
       type        = "*"
       identifiers = ["*"]
    }

    actions        = [
      "s3:GetObject",
    ]

    resources      = [
      "${aws_s3_bucket._.arn}/*",
    ]
  }
}


resource aws_s3_bucket_website_configuration _ {
  bucket   = aws_s3_bucket._.id
  index_document {
    suffix = "index.html"
  }
}


data template_file _ {
  template = file("./support/s3/index.html.tftpl")
  vars = {
    "endpoint_url" = aws_apigatewayv2_api._.api_endpoint
  }
}


resource aws_s3_object _ {
  key              = "index.html"
  bucket           = aws_s3_bucket._.id
  content          = data.template_file._.rendered
  content_encoding = "uft-8"
  content_type     = "text/html"
  content_language = "en"
  acl              = "private"
}
