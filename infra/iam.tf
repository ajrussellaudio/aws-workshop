
resource "aws_iam_role" "lambda_exec_role" {
  name = "aws-workshop-lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "aws-workshop-dynamodb_access_policy"
  description = "Policy for Lambda to access DynamoDB table"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query"
      ]
      Effect   = "Allow"
      Resource = [
        aws_dynamodb_table.items.arn,
        "${aws_dynamodb_table.items.arn}/index/gsi_1"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_iam_role" "api_gateway_invoke_lambda_role" {
  name = "api-gateway-invoke-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "api_gateway_invoke_lambda_policy" {
  name        = "api-gateway-invoke-lambda-policy"
  description = "Policy for API Gateway to invoke Lambda functions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "lambda:InvokeFunction"
      Effect   = "Allow"
      Resource = aws_lambda_function.authorizer.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_invoke_lambda_attachment" {
  role       = aws_iam_role.api_gateway_invoke_lambda_role.name
  policy_arn = aws_iam_policy.api_gateway_invoke_lambda_policy.arn
}

