# FSx for Windows File Server
resource "aws_fsx_windows_file_system" "fsx" {
  storage_capacity    = var.fsx_storage_gb
  subnet_ids          = var.private_subnet_ids
  preferred_subnet_id = var.private_subnet_ids[0]
  security_group_ids  = [aws_security_group.windowsfc.id]
  deployment_type     = "MULTI_AZ_1"
  throughput_capacity = 32
  active_directory_id = aws_directory_service_directory.ad.id
  
  # Storage type - SSD (performance optimized for SQL Server)
  storage_type = "SSD"
  
  # Weekly maintenance time - set to when you want maintenance to occur
  weekly_maintenance_start_time = "7:01:00"
  
  # Automatic backups - set appropriate values for your needs
  automatic_backup_retention_days = 7
  
  # FSx volume configuration
  self_managed_active_directory {
    dns_ips                    = aws_directory_service_directory.ad.dns_ip_addresses
    domain_name                = var.domain_name
    username                   = "Administrator"
    password                   = var.domain_admin_password
    organizational_unit_distinguished_name = "OU=Computers,DC=${split(".", var.domain_name)[0]},DC=${split(".", var.domain_name)[1]}"
  }
  
  # Enable shadow copies for SQL Server data protection
  audit_log_configuration {
    file_access_audit_log_level = "SUCCESS_AND_FAILURE"
    file_share_access_audit_log_level = "SUCCESS_AND_FAILURE" 
  }
  
  tags = {
    Name = "windowsfc-fsx"
  }
}
