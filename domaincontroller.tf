# Managed Microsoft AD
resource "aws_directory_service_directory" "ad" {
  name     = var.domain_name
  password = var.domain_admin_password
  size     = "Standard"
  type     = "MicrosoftAD"
  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.private_subnet_ids
  }
  tags = {
    Name = "windowsfc-ad"
  }
}
