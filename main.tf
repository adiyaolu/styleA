
module "studio-vpc-module" {
  source = "./infrastructure/api/aws_vpc"
  #version = "1.0.0"

  environment   = var.environment
  project       = var.project
  standard_tags = var.standard_tags

  # VPC
  vpc_cidr             = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy
  create_igw           = var.create_igw
  create_nat_gateway   = var.create_nat_gateway


  # Subnets and Route Tables
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs

  # IAM Role Variables

  role_name = var.role_name
  role_path = var.role_path

  # Cloudwatch Log Group

  cw_log_group_name = var.cw_log_group_name

  # VPC Flow Log

  create_flow_log      = true
  traffic_type         = var.traffic_type
  log_destination_type = var.log_destination_type
  log_format           = var.log_format
  file_format          = var.file_format
}

#RDS

module "db_cluster" {
  source = "./infrastructure/api/aws_rds"

  vpc_id  = module.studio-vpc-module.vpc_id[0]
  subnets = [module.studio-vpc-module.private_subnet_ids[1], module.studio-vpc-module.private_subnet_ids[2]]

  create_cluster = true
  project        = var.project        # "bluebite-studio"
  engine         = var.engine         #"aurora-postgresql"
  engine_version = var.engine_version #"11.12"

  is_primary_cluster = var.is_primary_cluster # true
  database_name      = var.database_name
  master_username    = var.master_username

  standard_tags = var.standard_tags # {}

  # DB instances
  cluster_instances = var.cluster_instances
}


module "configrules" {
  source = "./infrastructure/api/config_rules_configs3bucket"
  config-role = "var.config-role"
  bucket_name = "var.bucket_name"
}