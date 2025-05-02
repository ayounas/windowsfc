# IAM role for EC2s (SSM, CloudWatch, FSx join, etc.)
resource "aws_iam_role" "windowsfc" {
  name = "windowsfc-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.windowsfc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.windowsfc.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "fsx" {
  role       = aws_iam_role.windowsfc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonFSxFullAccess"
}

resource "aws_iam_instance_profile" "windowsfc" {
  name = "windowsfc-ec2-profile"
  role = aws_iam_role.windowsfc.name
}
