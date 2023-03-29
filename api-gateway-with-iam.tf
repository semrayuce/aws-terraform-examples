esource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "api_gateway_with_iam"
  description = "Api gateway to invoke lambda function"
}

resource "aws_api_gateway_method" "post_req" {
   rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
   resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
   http_method   = "POST"
   authorization = "AWS_IAM" 
   api_key_required = false

   request_models = {
    "application/json" = aws_api_gateway_model.api_req_model.name
  }
}

resource "aws_api_gateway_integration" "request_method_integration" {
   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
   resource_id = aws_api_gateway_method.post_req.resource_id
   http_method = aws_api_gateway_method.post_req.http_method

   integration_http_method = "POST"
   type                    = "AWS"
   uri                     = "${data.aws_lambda_function.lambda_function.invoke_arn}"
}

resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.post_req.resource_id
  http_method = aws_api_gateway_method.post_req.http_method
  status_code = "200"
}


resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.post_req.resource_id
  http_method = aws_api_gateway_method_response.response_method.http_method
  status_code = aws_api_gateway_method_response.response_method.status_code

  depends_on = [
    aws_api_gateway_integration.request_method_integration
  ]
}

resource "aws_api_gateway_deployment" "api_deploy" {
   depends_on = [
     aws_api_gateway_integration.request_method_integration,
   ]

   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
   stage_name  = var.stage
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "api_key"
}

resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name = "api_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_deployment.api_deploy.stage_name
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

resource "aws_api_gateway_model" "api_req_model" {
  rest_api_id  = aws_api_gateway_rest_api.api_gateway.id
  name         = "api_req_model"
  description  = "Request model"
  content_type = "application/json"

  schema = jsonencode({
    "type" : "object",
    "required" : ["Name", "Surname"],
    "properties" : {
    "Name" : {
      "type" : "string"
    },
    "Surname" : {
      "type" : "string"
    }
  }
  })
}

#######################################
# API Gateway IAM Authorization
#######################################
data "aws_iam_policy_document" "api_policy_doc" {
   statement {
      effect = "Allow"
      actions = ["execute-api:Invoke", "lambda:InvokeFunction"]
      resources = ["arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.api_gateway.id}/*/*/*","arn:aws:lambda:${local.region}:${local.account_id}:${data.aws_lambda_function.lambda_function.function_name}]
   }
}

resource "aws_iam_user" "api_gateway_user" {
  name = "api-execute-user"
  path = "/system/"
}

resource "aws_iam_policy" "policy" {
   name = "api-execute-policy"
   policy = data.aws_iam_policy_document.api_policy_doc.json
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.api_gateway_user.name
  policy_arn = aws_iam