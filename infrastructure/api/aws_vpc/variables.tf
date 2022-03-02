# Common Variables

variable "environment" {
  description = "Environment Tag"
  type        = string
  default     = ""
}

variable "project" {
  description = "Application Name"
  type        = string
  default     = ""
}

# VPC Variables

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "enable_dns_support" {
  description = "Whether or not the VPC has DNS support. Acceptable values: true or false"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support. Acceptable values: true or false"
  type        = bool
  default     = false
}

variable "instance_tenancy" {
  description = "Instance Tenancy"
  type        = string
  default     = "default"
}

variable "enable_classiclink" {
  description = "Whether or not classic link be enabled. Acceptable values: true or false"
  type        = bool
  default     = false
}

variable "enable_classiclink_dns_support" {
  description = "Whether or not classic link dns support be enabled. Acceptable values: true or false"
  type        = bool
  default     = false
}

variable "standard_tags" {
  description = "Standard Taggings"
  type        = map(string)
  default     = {}
}

# VPC DHCP Options Variables

variable "create_dhcp_options" {
  description = "Whether the DHCP option needs creating. Acceptable values: true or false"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = ""
}

variable "domain_name_servers" {
  description = "Domain name server"
  type        = list(string)
  default     = []
}

variable "ntp_servers" {
  description = "Ntp servers"
  type        = list(string)
  default     = []
}

variable "netbios_name_servers" {
  description = "Netbios name servers"
  type        = list(string)
  default     = []
}

variable "netbios_node_type" {
  description = "Netbios node type"
  type        = string
  default     = ""
}

# Internet Gateway Variables

variable "create_igw" {
  description = "Whether or not the Internet gateway be created, Acceptable values: true or false"
  type        = bool
  default     = false
}

# EIP and Nat Gateway Variables

variable "create_nat_gateway" {
  description = "The CIDR block for the VPC"
  type        = bool
  default     = false
}

# Subnets Variables

variable "availability_zones" {
  description = "Availability Zones for subnets"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Whether the Public Ip should be assigned, Acceptable values: true or false"
  type        = bool
  default     = true
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

# IAM Role Variables

variable "role_name" {
  description = "Name of the VPC Flow Log role"
  type        = string
  default     = ""
}

variable "role_path" {
  description = "Path for the VPC Flow Log role"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the specified role"
  type        = number
  default     = 3600
}

# Cloudwatch Log Group

variable "cw_log_group_name" {
  description = "CloudWatch Log Group Name"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Number of Days the logs should be retained. Acceptable values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0(always retain, never expire)"
  type        = number
  default     = 0
}

variable "kms_key_id" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

# VPC Flow Log

variable "create_flow_log" {
  description = "Whether the FlowLogs needs creating. Acceptable values: true or false"
  type        = bool
  default     = false
}

variable "traffic_type" {
  description = "The type of traffic to capture. Acceptable values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
}

variable "log_destination_type" {
  description = "The type of the logging destination. Acceptable values: cloud-watch-logs, s3"
  type        = string
  default     = "cloud-watch-logs"
}

variable "log_format" {
  description = "The fields to include in the flow log record"
  type        = string
  default     = ""
}

variable "max_aggregation_interval" {
  description = "The maximum interval of time(in seconds) during which a flow of packets is captured and aggregated. Acceptable values: 60 or 600"
  type        = number
  default     = 600
}
variable "file_format" {
  description = "The format for the flow log. Acceptable Values: plain-text, parquet"
  type        = string
  default     = "plain-text"
}

variable "hive_compatible_partitions" {
  description = "Whether to use Hive-compatible prefixes for flow logs stored in Amazon S3. Acceptable Values: true or false"
  type        = bool
  default     = false
}

variable "per_hour_partition" {
  description = "Whether to partition the flow log per hour. Acceptable Values: true or false"
  type        = bool
  default     = false
}