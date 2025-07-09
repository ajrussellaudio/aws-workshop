
resource "aws_dynamodb_table" "items" {
  name           = "aws-workshop-items"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
