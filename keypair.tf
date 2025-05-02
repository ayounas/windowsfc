# Key pair for EC2 access
resource "tls_private_key" "windowsfc" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "windowsfc" {
  key_name   = var.key_name
  public_key = tls_private_key.windowsfc.public_key_openssh
}

resource "local_file" "windowsfc_private_key" {
  content  = tls_private_key.windowsfc.private_key_pem
  filename = "${path.module}/windowsfc-key.pem"
}
