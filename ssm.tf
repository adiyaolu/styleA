# Add VPC and SUBNET ID's to SSM
resource "aws_ssm_parameter" "studio_vpc" {
  name  = "studio-vpc-id"
  type  = "String"
  value = module.studio-vpc-module.vpc_id[0]
}

resource "aws_ssm_parameter" "studio_private_subnet_a" {
  name  = "studio-private-subnet-a"
  type  = "String"
  value = module.studio-vpc-module.private_subnet_ids[0]
}

resource "aws_ssm_parameter" "studio_studio_private_subnet_b" {
  name  = "studio-private-subnet-b"
  type  = "String"
  value = module.studio-vpc-module.private_subnet_ids[1]
}

resource "aws_ssm_parameter" "studio_private_subnet_c" {
  name  = "studio-private-subnet-c"
  type  = "String"
  value = module.studio-vpc-module.private_subnet_ids[2]
}

resource "aws_ssm_parameter" "studio_public_subnet_a" {
  name  = "studio-public-subnet-a"
  type  = "String"
  value = module.studio-vpc-module.public_subnet_ids[0]
}

resource "aws_ssm_parameter" "studio_public_subnet_b" {
  name  = "studio-public-subnet-b"
  type  = "String"
  value = module.studio-vpc-module.public_subnet_ids[1]
}

resource "aws_ssm_parameter" "studio_public_subnet_c" {
  name  = "studio-public-subnet-c"
  type  = "String"
  value = module.studio-vpc-module.public_subnet_ids[2]
}
