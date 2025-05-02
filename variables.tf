# Variables for VPC, subnets, domain, passwords, region, etc.
variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "VPC ID to deploy resources into."
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "Active Directory domain name."
  type        = string
  default     = "corp.local"
}

variable "domain_admin_password" {
  description = "Domain admin password. Set via TF_VAR_domain_admin_password env var."
  type        = string
  sensitive   = true
}

variable "fsx_storage_gb" {
  description = "FSx storage size in GB."
  type        = number
  default     = 300
}

variable "sql_server_admin_password" {
  description = "SQL Server admin password. Set via TF_VAR_sql_server_admin_password env var."
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type for cluster nodes."
  type        = string
  default     = "m5.large"
}

variable "key_name" {
  description = "Name of the EC2 key pair."
  type        = string
  default     = "windowsfc-key"
}

variable "cloudwatch_log_group" {
  description = "CloudWatch log group name."
  type        = string
  default     = "/aws/windowsfc"
}

variable "cluster_ip" {
  description = "Virtual IP address for the Windows Failover Cluster."
  type        = string
  default     = ""
}

variable "witness_share_name" {
  description = "Name of the FSx share to use for cluster quorum witness."
  type        = string
  default     = "witness"
}

variable "cluster_name" {
  description = "Name of the Windows Failover Cluster."
  type        = string
  default     = "SQLCLUSTER"
}
