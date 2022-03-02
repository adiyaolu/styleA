resource "aws_flow_log" "this" {

  count = var.create_flow_log ? 1 : 0

  traffic_type             = var.traffic_type
  iam_role_arn             = aws_iam_role.vpc_flow_log.arn
  log_destination_type     = var.log_destination_type
  log_destination          = aws_cloudwatch_log_group.vpc_flow_log.arn
  vpc_id                   = element(aws_vpc.this.*.id, 0)
  log_format               = var.log_format
  max_aggregation_interval = var.max_aggregation_interval

  dynamic "destination_options" {
    for_each = var.log_destination_type == "s3" ? [true] : []
    content {
      file_format                = var.file_format
      hive_compatible_partitions = var.hive_compatible_partitions
      per_hour_partition         = var.per_hour_partition
    }
  }

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = var.cw_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_id

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}
