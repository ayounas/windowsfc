# Outputs for connection, FSx, etc.
output "key_pair_private_key_path" {
  value = local_file.windowsfc_private_key.filename
}

output "fsx_dns_name" {
  value = aws_fsx_windows_file_system.fsx.dns_name
}

output "cluster_node_ips" {
  value = [for i in aws_instance.cluster_nodes : i.private_ip]
}

output "ad_dns_ips" {
  value = aws_directory_service_directory.ad.dns_ip_addresses
}
