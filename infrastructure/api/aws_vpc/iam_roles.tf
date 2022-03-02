data "aws_iam_policy_document" "assume_role" {

  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_log" {
  name                 = var.role_name
  description          = "IAM roles for VPC Flow Logs"
  path                 = var.role_path
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns  = var.managed_policy_arns
  max_session_duration = var.max_session_duration

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    sid    = "CloudWatchLogsPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cw_logs" {
  name   = format("%s-%s", "vpc-flow-logs-role-policy-", var.project)
  role   = aws_iam_role.vpc_flow_log.id
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}