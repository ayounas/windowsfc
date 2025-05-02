# Example tfvars for Windows Failover Cluster in AWS
region = "eu-west-2"
vpc_id = "vpc-xxxxxxxx"
private_subnet_ids = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
domain_name = "corp.local"
domain_admin_password = "${var.domain_admin_password}"
sql_server_admin_password = "${var.sql_server_admin_password}"
fsx_storage_gb = 300
instance_type = "m5.2xlarge" # Recommended for SQL Server production
key_name = "windowsfc-key"
cloudwatch_log_group = "/aws/windowsfc"

# Failover Cluster configuration
cluster_name = "SQLCLUSTER"
cluster_ip = "10.0.1.100" # Virtual IP for the cluster within your subnet CIDR
witness_share_name = "witness"
