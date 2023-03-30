module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name      = "lambda-function"
  description        = "Lambda function"
  handler            = "lambda.lambda_handler"
  runtime            = var.python_version
  timeout            = 10
  attach_policy_json = true
  policy_json        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Action": [
        "dynamodb:PutItem",
				"dynamodb:UpdateItem"
    ],
    "Resource": "arn:aws:dynamodb:${local.region}:${local.account_id}:table/SampleTable",
    "Effect": "Allow"
    }
  ]
}
EOF
  source_path = [
   {
      path             = "./lambda",
      pip_requirements = true
  }
 ]
}

data "aws_lambda_function" "lambda_function" {
  function_name = module.lambda_function.lambda_function_name
}  
