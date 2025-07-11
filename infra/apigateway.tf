
resource "aws_api_gateway_rest_api" "api" {
  name        = "aws-workshop-serverless_api"
  description = "API for CRUD operations"
}

resource "aws_api_gateway_authorizer" "token_authorizer" {
  name                   = "token_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.api_gateway_invoke_lambda_role.arn
  type                   = "TOKEN"
  identity_source        = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 0
}


resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_resource" "item" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.items.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "create_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

resource "aws_api_gateway_integration" "create_item_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.items.id
  http_method = aws_api_gateway_method.create_item_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.create_item.invoke_arn
}

resource "aws_api_gateway_method" "read_all_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

resource "aws_api_gateway_integration" "read_all_item_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.items.id
  http_method = aws_api_gateway_method.read_all_item_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.read_all_item.invoke_arn
}

resource "aws_api_gateway_method" "read_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

resource "aws_api_gateway_integration" "read_item_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.read_item_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.read_item.invoke_arn
}

resource "aws_api_gateway_method" "update_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

resource "aws_api_gateway_integration" "update_item_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.update_item_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.update_item.invoke_arn
}

resource "aws_api_gateway_method" "delete_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "DELETE"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

resource "aws_api_gateway_integration" "delete_item_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.delete_item_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.delete_item.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.create_item_integration,
      aws_api_gateway_integration.read_all_item_integration,
      aws_api_gateway_integration.read_item_integration,
      aws_api_gateway_integration.update_item_integration,
      aws_api_gateway_integration.delete_item_integration,
      aws_api_gateway_authorizer.token_authorizer,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.create_item_integration,
    aws_api_gateway_integration.read_all_item_integration,
    aws_api_gateway_integration.read_item_integration,
    aws_api_gateway_integration.update_item_integration,
    aws_api_gateway_integration.delete_item_integration,
    aws_api_gateway_authorizer.token_authorizer,
  ]
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

output "api_url" {
  value = aws_api_gateway_stage.api_stage.invoke_url
}
