###############################################################################
# module: root
###############################################################################

###############################################################################
# dynamodb

resource "aws_dynamodb_table" "udemy_course" {
  name                        = "UdemyCourse"
  billing_mode                = "PROVISIONED"
  read_capacity               = 1
  write_capacity              = 1
  table_class                 = "STANDARD"
  deletion_protection_enabled = false

  hash_key = "PartitionKey"
  attribute {
    name = "PartitionKey"
    type = "S"
  }

  range_key = "SortKey"
  attribute {
    name = "SortKey"
    type = "S"
  }
}
