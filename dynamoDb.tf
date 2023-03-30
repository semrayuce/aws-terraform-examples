resource "aws_dynamodb_table" "sample-dynamodb-table" {
  name           = "SampleTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"
  range_key      = "User"

  attribute {
    name = "UserId"
    type = "N"
  }

  attribute {
    name = "User"
    type = "S"
  }
}