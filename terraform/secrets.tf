data "aws_secretsmanager_secret" "username" {
  name = "wax-match/aws-tf-user"
}

data "aws_secretsmanager_secret_version" "username" {
  secret_id = data.aws_secretsmanager_secret.username.id
}
