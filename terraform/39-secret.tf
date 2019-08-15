resource "random_string" "random" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "inlets_token" {
  name = "${var.project}-token"
}

resource "aws_secretsmanager_secret_version" "inlets_token" {
  secret_id     = "${aws_secretsmanager_secret.inlets_token.id}"
  secret_string = "${random_string.random.result}"
}

data "aws_iam_policy_document" "inlets_token" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "${aws_secretsmanager_secret_version.inlets_token.arn}",
    ]
  }
}

resource "aws_iam_policy" "inlets_token" {
  policy = "${data.aws_iam_policy_document.inlets_token.json}"
}
