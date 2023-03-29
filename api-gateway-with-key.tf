resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "api_gateway_with_key"
  description = "Api gateway to invoke lambda function"
}

resource "aws_api_gateway_method" "post_req" {
   rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
   resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
   http_method   = "POST"
   authorization = "NONE"
   api_key_required = true
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
   resource_id = aws_api_gateway_method.post_req.resource_id
   http_method = aws_api_gateway_method.post_req.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = "${data.aws_lambda_function.lambda_function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "apideploy" {
   depends_on = [
     aws_api_gateway_integration.lambda,
   ]

   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
   stage_name  = var.stage_name
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "api_key"
}

resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name = var.api_name

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_deployment.apideploy.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "api_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}


resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = "${data.aws_lambda_function.lambda_function.function_name}"
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}