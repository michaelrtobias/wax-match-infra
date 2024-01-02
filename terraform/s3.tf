resource "aws_s3_bucket" "wax_matcher_tf_state" {
  bucket = "wax-matcher-tf-state"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "wax_matcher_tf_state" {
  bucket = aws_s3_bucket.wax_matcher_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_user" "user" {
  user_name = jsondecode(data.aws_secretsmanager_secret_version.username.secret_string)["username"]
}

data "aws_s3_object" "wax_matcher_tf_state" {
  bucket = aws_s3_bucket.wax_matcher_tf_state.id
  key    = "state/api/terraform.tfstate"
}

resource "aws_s3_bucket_policy" "wax_matcher_tf_state" {
  bucket = aws_s3_bucket.wax_matcher_tf_state.id
  policy = data.aws_iam_policy_document.wax_matcher_tf_state.json
}


data "aws_iam_policy_document" "wax_matcher_tf_state" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.user.arn]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "${aws_s3_bucket.wax_matcher_tf_state.arn}",
      "${aws_s3_bucket.wax_matcher_tf_state.arn}/*",
    ]
  }
  # statement {
  #   principals {
  #     type        = "AWS"
  #     identifiers = [data.aws_iam_user.user.arn]
  #   }
  #   actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]

  #   resources = [
  #     "s3://${aws_s3_bucket.wax_matcher_tf_state.arn}/${data.aws_s3_object.wax_matcher_tf_state.key}",
  #     "s3://${aws_s3_bucket.wax_matcher_tf_state.arn}/${data.aws_s3_object.wax_matcher_tf_state.key}/*",
  #   ]
  # }
}


resource "aws_dynamodb_table" "wax_matcher_tf_state" {
  name           = "wax_matcher_tf_state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
