# --- Jenkins EC2 IAM Role ---
resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_prefix}-jenkins-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_power_user" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy" "jenkins_ssm_policy" {
  name   = "${var.project_prefix}-jenkins-ssm"
  role   = aws_iam_role.jenkins_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ssm:GetParameter", "ssm:GetParameters"]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_prefix}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_prefix}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# --- K3s Node IAM Role ---
resource "aws_iam_role" "k3s_role" {
  name = "${var.project_prefix}-k3s-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "k3s_ecr_read_only" {
  role       = aws_iam_role.k3s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy" "k3s_ssm_policy" {
  name   = "${var.project_prefix}-k3s-ssm"
  role   = aws_iam_role.k3s_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:PutParameter"]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_prefix}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "k3s_profile" {
  name = "${var.project_prefix}-k3s-profile"
  role = aws_iam_role.k3s_role.name
}
