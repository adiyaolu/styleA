# Common Variables
environment = "dev"
project     = "studio"
service     = "api"
region      = "us-east-1"
standard_tags = {
  environment = "dev"
  project     = "studio"
  service     = "api"
}

# VPC Variables
vpc_cidr             = "10.0.0.0/16"
enable_dns_hostnames = true
instance_tenancy     = "default"

# Subnets and Route Tables
public_subnet_cidrs  = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnet_cidrs = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]

# IAM Role Variables
role_name = "studio-vpc-flowlog"

# Cloudwatch Log Group
cw_log_group_name = "studio-vpc-flowlog-dev"

# VPC Flow Log

traffic_type         = "ALL"
log_destination_type = "cloud-watch-logs"
#log_format = "" If we dont have a specific format, default format will be used
file_format = "plain-text"


#rds
create_cluster = true
engine         = "aurora-postgresql"
engine_version = "12.7"

is_primary_cluster = true
database_name      = "studio_editor_api_dev"
master_username    = "master"


db_subnet_group_name = "studio_subnet_group_dev"
engine_mode          = "global"

# DB instances
cluster_instances = {
  "rds-1-instance" = {
    instance_class    = "db.r5.large"
    availability_zone = "us-east-1b"
  },
  "rds-2-instance" = {
    instance_class    = "db.r5.large"
    availability_zone = "us-east-1c"
  }
}

config-role= "studio-config-dev"
bucket_name = "configlogs"