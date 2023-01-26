resource "random_string" "random" {
  length = 4
  special = false
}

resource "aws_secretsmanager_secret" "secret" {
  name = "${var.name}-${random_string.random.result}"
}

resource "aws_secretsmanager_secret_version" "secret_string" {
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.secret_string)
}
