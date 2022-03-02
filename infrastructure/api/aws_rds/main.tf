locals {
  backtrack_window            = (var.engine == "aurora-mysql" || var.engine == "aurora") ? var.backtrack_window : 0
  rds_enhanced_monitoring_arn = var.create_monitoring_role ? join("", aws_iam_role.rds_enhanced_monitoring.*.arn) : var.monitoring_role_arn
}

data "aws_partition" "current" {}

# Random string to use as master password

resource "random_id" "snapshot_identifier" {
  count = var.create_cluster ? 1 : 0

  keepers = {
    id = var.project
  }

  byte_length = 4
}
resource "random_password" "studio_db_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers = {
    pass_version = 1
  }
}
resource "aws_secretsmanager_secret" "studio-db-pass" {
  name = "studio-db-pass-secrett"
}
resource "aws_secretsmanager_secret_version" "db-pass-val" {
  secret_id     = aws_secretsmanager_secret.studio-db-pass.id
  secret_string = random_password.studio_db_master_pass.result
}

resource "aws_rds_cluster" "this" {

  global_cluster_identifier      = var.global_cluster_identifier
  enable_global_write_forwarding = var.enable_global_write_forwarding
  cluster_identifier             = var.project
  replication_source_identifier  = var.replication_source_identifier
  source_region                  = var.source_region

  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  enable_http_endpoint                = var.enable_http_endpoint
  kms_key_id                          = var.kms_key_id
  database_name                       = var.database_name
  master_username                     = var.master_username
  master_password                     = random_password.studio_db_master_pass.result
  final_snapshot_identifier           = "${var.final_snapshot_identifier_prefix}-${var.project}-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = 5306
  db_subnet_group_name                = aws_db_subnet_group.this[0].name
  vpc_security_group_ids              = compact(concat([aws_security_group.this.id], var.vpc_security_group_ids))
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.this[0].name
  db_instance_parameter_group_name    = var.allow_major_version_upgrade ? var.db_cluster_db_instance_parameter_group_name : null
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backtrack_window                    = local.backtrack_window
  copy_tags_to_snapshot               = true
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    update = lookup(var.cluster_timeouts, "update", null)
    delete = lookup(var.cluster_timeouts, "delete", null)
  }

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  dynamic "restore_to_point_in_time" {
    for_each = length(keys(var.restore_to_point_in_time)) == 0 ? [] : [var.restore_to_point_in_time]

    content {
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      restore_type               = lookup(restore_to_point_in_time.value, "restore_type", null)
      use_latest_restorable_time = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
      restore_to_time            = lookup(restore_to_point_in_time.value, "restore_to_time", null)
    }
  }

  lifecycle {
    ignore_changes = [
      replication_source_identifier,
      global_cluster_identifier,
    ]
  }

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

resource "aws_rds_cluster_instance" "this" {
  for_each = var.create_cluster ? var.cluster_instances : {}

  identifier                            = var.instances_use_identifier_prefix ? null : lookup(each.value, "identifier", "${var.project}-${each.key}")
  identifier_prefix                     = var.instances_use_identifier_prefix ? lookup(each.value, "identifier_prefix", "${var.project}-${each.key}-") : null
  cluster_identifier                    = try(aws_rds_cluster.this.id, "")
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = lookup(each.value, "instance_class", var.instance_class)
  publicly_accessible                   = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  db_subnet_group_name                  = aws_db_subnet_group.this[0].name
  db_parameter_group_name               = aws_db_parameter_group.this[0].name
  apply_immediately                     = lookup(each.value, "apply_immediately", var.apply_immediately)
  monitoring_role_arn                   = local.rds_enhanced_monitoring_arn
  monitoring_interval                   = lookup(each.value, "monitoring_interval", var.monitoring_interval)
  promotion_tier                        = lookup(each.value, "promotion_tier", null)
  availability_zone                     = lookup(each.value, "availability_zone", null)
  preferred_maintenance_window          = lookup(each.value, "preferred_maintenance_window", var.preferred_maintenance_window)
  auto_minor_version_upgrade            = lookup(each.value, "auto_minor_version_upgrade", var.auto_minor_version_upgrade)
  performance_insights_enabled          = lookup(each.value, "performance_insights_enabled", var.performance_insights_enabled)
  performance_insights_kms_key_id       = lookup(each.value, "performance_insights_kms_key_id", var.performance_insights_kms_key_id)
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", var.performance_insights_retention_period)
  copy_tags_to_snapshot                 = true
  ca_cert_identifier                    = var.ca_cert_identifier

  timeouts {
    create = lookup(var.instance_timeouts, "create", null)
    update = lookup(var.instance_timeouts, "update", null)
    delete = lookup(var.instance_timeouts, "delete", null)
  }

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

resource "aws_rds_cluster_endpoint" "this" {
  for_each = var.create_cluster ? var.endpoints : tomap({})

  cluster_identifier          = try(aws_rds_cluster.this.id, "")
  cluster_endpoint_identifier = each.value.identifier
  custom_endpoint_type        = each.value.type

  static_members   = lookup(each.value, "static_members", null)
  excluded_members = lookup(each.value, "excluded_members", null)

  depends_on = [
    aws_rds_cluster_instance.this
  ]

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

resource "aws_rds_cluster_role_association" "this" {
  for_each = var.create_cluster && length(var.iam_roles) > 0 ? var.iam_roles : {}

  db_cluster_identifier = try(aws_rds_cluster.this.id, "")
  feature_name          = each.value.feature_name
  role_arn              = each.value.role_arn
}

################################################################################
# Autoscaling
################################################################################

resource "aws_appautoscaling_target" "this" {
  count = var.create_cluster && var.autoscaling_enabled ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "cluster:${try(aws_rds_cluster.this.cluster_identifier, "")}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "this" {
  count = var.create_cluster && var.autoscaling_enabled ? 1 : 0

  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${try(aws_rds_cluster.this.cluster_identifier, "")}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.autoscaling_target_cpu : var.autoscaling_target_connections
  }

  depends_on = [
    aws_appautoscaling_target.this
  ]
}
