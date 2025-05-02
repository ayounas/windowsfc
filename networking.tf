# Networking: VPC, subnets, security groups
# Use data sources for existing VPC/subnets if provided, or create if not
# Security groups for AD, FSx, EC2 cluster nodes

resource "aws_security_group" "windowsfc" {
  name        = "windowsfc-sg"
  description = "Security group for Windows Failover Cluster"
  vpc_id      = var.vpc_id

  # Windows Failover Cluster Ports
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # RDP, restrict as needed
  }
  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SMB, restrict as needed
  }
  ingress {
    from_port   = 135
    to_port     = 139
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # RPC, NetBIOS, restrict as needed
  }
  
  # Windows Failover Cluster (Core)
  ingress {
    description = "Windows Failover Cluster"
    from_port   = 3343
    to_port     = 3343
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Windows Failover Cluster"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    self        = true
  }
  
  # SQL Server Ports
  ingress {
    description = "SQL Server"
    from_port   = 1433
    to_port     = 1434
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "SQL Server Always On"
    from_port   = 5022
    to_port     = 5023
    protocol    = "tcp"
    self        = true
  }
  
  # Heartbeat and Node Communication
  ingress {
    description = "Heartbeat"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    self        = true
  }
  
  # Ephemeral Ports 
  ingress {
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }
  ingress {
    from_port   = 49152
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }
  
  # Allow All Traffic Between Cluster Nodes
  ingress {
    description = "All internal cluster traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "windowsfc-sg"
  }
}