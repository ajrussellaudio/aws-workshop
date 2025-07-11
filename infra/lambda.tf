resource "null_resource" "build_lambdas" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "npm run build"
    working_dir = "${path.module}/../src/services"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/services/dist"
  output_path = "${path.module}/../src/services/dist/handler.zip"
  depends_on = [null_resource.build_lambdas]
}

resource "aws_lambda_function" "read_all_item" {
  function_name = "aws-workshop-read_all_item"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "read-all.handler"
  runtime       = "nodejs16.x"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_read_all" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_all_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/${aws_api_gateway_stage.api_stage.stage_name}/${aws_api_gateway_method.read_all_item_method.http_method}${aws_api_gateway_resource.items.path}"
}

resource "aws_lambda_function" "create_item" {
  function_name = "aws-workshop-create_item"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "create.handler"
  runtime       = "nodejs16.x"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_create" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/${aws_api_gateway_stage.api_stage.stage_name}/${aws_api_gateway_method.create_item_method.http_method}${aws_api_gateway_resource.items.path}"
}

resource "aws_lambda_function" "read_item" {
  function_name = "aws-workshop-read_item"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "read.handler"
  runtime       = "nodejs16.x"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_read" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/${aws_api_gateway_stage.api_stage.stage_name}/${aws_api_gateway_method.read_item_method.http_method}${aws_api_gateway_resource.item.path}"
}

resource "aws_lambda_function" "update_item" {
  function_name = "aws-workshop-update_item"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "update.handler"
  runtime       = "nodejs16.x"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_update" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/${aws_api_gateway_stage.api_stage.stage_name}/${aws_api_gateway_method.update_item_method.http_method}${aws_api_gateway_resource.item.path}"
}

resource "aws_lambda_function" "delete_item" {
  function_name = "aws-workshop-delete_item"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "delete.handler"
  runtime       = "nodejs16.x"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_delete" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/${aws_api_gateway_stage.api_stage.stage_name}/${aws_api_gateway_method.delete_item_method.http_method}${aws_api_gateway_resource.item.path}"
}

resource "aws_lambda_function" "authorizer" {
  function_name = "aws-workshop-authorizer"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "authorizer.handler"
  runtime       = "nodejs16.x"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      AUTH_TOKEN = var.auth_token
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_authorizer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/authorizers/${aws_api_gateway_authorizer.token_authorizer.id}"
}
