# Get availability zones for the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Cluster nodes (Windows Server 2019, join domain, install SQL Server 2022, CloudWatch agent)
data "aws_ssm_parameter" "win2019_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base"
}

resource "aws_instance" "cluster_nodes" {
  count         = 2
  ami           = data.aws_ssm_parameter.win2019_ami.value
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  key_name      = aws_key_pair.windowsfc.key_name
  vpc_security_group_ids = [aws_security_group.windowsfc.id]
  iam_instance_profile   = aws_iam_instance_profile.windowsfc.name
  
  # Enable ENA for optimized networking (better cluster performance)
  ebs_optimized = true

  # Root volume with sufficient storage for SQL Server
  root_block_device {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
  }

  # Add additional volumes for SQL Server data/logs
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
    delete_on_termination = true
  }

  tags = {
    Name = "windowsfc-sqlnode-${count.index + 1}"
  }

  user_data = templatefile("${path.module}/scripts/userdata.ps1.tftpl", {
    domain_name                = var.domain_name
    domain_admin_password      = var.domain_admin_password
    sql_server_admin_password  = var.sql_server_admin_password
    fsx_dns_name               = aws_fsx_windows_file_system.fsx.dns_name
    fsx_mount_name             = aws_fsx_windows_file_system.fsx.windows_volume_configuration[0].file_system_mount_point
    cloudwatch_log_group       = var.cloudwatch_log_group
    node_index                 = count.index
    node_count                 = 2
    cluster_name               = var.cluster_name
    cluster_ip                 = var.cluster_ip
    witness_share_name         = var.witness_share_name
  })

  # Avoid dependency cycle issues
  depends_on = [
    aws_directory_service_directory.ad,
    aws_fsx_windows_file_system.fsx
  ]
}

# Schedule the cluster test to run once deployment is complete
resource "null_resource" "run_cluster_tests" {
  # Run the tests only after both nodes are fully deployed
  depends_on = [aws_instance.cluster_nodes]

  # Run the test 30 minutes after deployment to ensure everything is running
  # This uses a provisioner to execute a command on the local machine that runs terraform
  provisioner "local-exec" {
    command = <<EOT
      # Wait for cluster to fully initialize (30 minutes)
      echo "Waiting 30 minutes for cluster to fully initialize before running tests..."
      sleep 1800
      
      # Use AWS Systems Manager to execute the test script on the primary node
      aws ssm send-command \
        --document-name "AWS-RunPowerShellScript" \
        --targets "Key=tag:Name,Values=windowsfc-sqlnode-1" \
        --parameters "commands=[
          \"$${content}\"
        ]" \
        --region ${var.region} \
        --output text
    EOT
    
    environment = {
      content = templatefile("${path.module}/scripts/cluster_tests.ps1.tftpl", {
        domain_name                = var.domain_name
        cloudwatch_log_group       = var.cloudwatch_log_group
        fsx_dns_name               = aws_fsx_windows_file_system.fsx.dns_name
        fsx_mount_name             = aws_fsx_windows_file_system.fsx.windows_volume_configuration[0].file_system_mount_point
        cluster_name               = var.cluster_name
        witness_share_name         = var.witness_share_name
      })
    }
  }
}
