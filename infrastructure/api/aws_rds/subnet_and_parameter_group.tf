resource "aws_db_subnet_group" "this" {
  count = var.create_cluster ? 1 : 0

  name        = format("%s-%s", var.project, "aurora-db-subnet-group")
  description = format("%s-%s", var.project, " Aurora DB Subet Group")
  subnet_ids  = var.subnets

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

resource "aws_db_parameter_group" "this" {
  count = var.create_cluster ? 1 : 0

  name        = format("%s-%s", var.project, "aurora-db-parameter-group")
  family      = "aurora-postgresql12"
  description = format("%s-%s", var.project, "Aurora DB Parameter Group")
  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.create_cluster ? 1 : 0

  name        = format("%s-%s", var.project, "aurora-cluster-parameter-group")
  family      = "aurora-postgresql12"
  description = format("%s-%s", var.project, "Aurora Cluster Parameter Group")
  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}
