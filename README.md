# aws-terraform-examples
Api-gateway to invoke lambda function and insert data to dynamoDB.

![aws_logos](https://user-images.githubusercontent.com/6909124/228962653-7e80c637-0645-4932-8cac-599f51a5b1af.png)

Both IAM role and api-key authorizers are provided for api-gateway. Currently, IAM role is activated. Swich it to api-key based authorization in aws_api_gateway_method resource with:
- authorization = "NONE"
- api_key_required = true


## Prerequisites
| Name       | Version  |
| ---------- |----------|
| Terraform  |  ~>1.4.0 |
| Python     |  3.8     |


## Use Cases
- Create API Gateway
- Create IAM role for authorization
- Create Api-key for authorization
- Create usage plan for api key
- Create json model for post request
- Create & develop Lambda function
- Create permission to invoke lambda from api-gateway
- Create DynamoDb table

## How to Use
- Terraform init
- Terrraform plan
- Terraform apply

