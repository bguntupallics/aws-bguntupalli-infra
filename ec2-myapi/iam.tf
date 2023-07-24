#-----------------------------------------------------------------------------------------------------------------------
# EC2 Instance Role Resources
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "ec2-role" {
  name        = "${var.environment}-${var.deployment_id}-${var.service}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  //  tags = local.common_tags
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name        = "${var.environment}-${var.deployment_id}-${var.service}-instance-profile"
  role        = aws_iam_role.ec2-role.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2-role.name
}

resource "aws_iam_role_policy" "ssh" {
  role        = aws_iam_role.ec2-role.name
  name        = "${var.environment}-${var.deployment_id}-${var.service}-ssh-policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "ec2:Describe*",
        "Resource": ["*"]
      },
      {
        "Effect": "Allow",
        "Action": "ssm:StartSession",
        "Resource": [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ssm:*:*:document/AWS-StartSSHSession",
          "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "ecr:GetAuthorizationToken",
        "Resource": "*"
      }
    ]
}
EOF
}