resource "aws_cloudwatch_log_group" "fluent_bit_log_group" {
  name              = "${var.env}/cluster/logs"
  retention_in_days = 14
  tags = {
    Environment = var.env
  }
}


resource "aws_iam_role" "fluent_bit_role" {
  name = "${var.env}-fluent-bit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${aws_iam_openid_connect_provider.cluster.url}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.cluster.url}:sub": "system:serviceaccount:logging:fluent-bit"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "fluent_bit_policy" {
  name = "${var.env}-fluent-bit-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:${var.env}/cluster/logs:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit_role_policy_attachment" {
  role       = aws_iam_role.fluent_bit_role.name
  policy_arn = aws_iam_policy.fluent_bit_policy.arn
}
