provider "aws" {
  region = "ap-south-1"
}

# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "trend_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "trend-vpc"
  }
}

# ---------------------------
# Public Subnet 1 (AZ-1a)
# ---------------------------
resource "aws_subnet" "trend_subnet_1" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                              = "trend-public-subnet-1a"
    "kubernetes.io/cluster/trend-eks" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

# ---------------------------
# Public Subnet 2 (AZ-1b)
# ---------------------------
resource "aws_subnet" "trend_subnet_2" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                              = "trend-public-subnet-1b"
    "kubernetes.io/cluster/trend-eks" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id

  tags = {
    Name = "trend-igw"
  }
}

# ---------------------------
# Route Table
# ---------------------------
resource "aws_route_table" "trend_rt" {
  vpc_id = aws_vpc.trend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }

  tags = {
    Name = "trend-public-rt"
  }
}

# ---------------------------
# Route Table Associations
# ---------------------------
resource "aws_route_table_association" "trend_rta_1" {
  subnet_id      = aws_subnet.trend_subnet_1.id
  route_table_id = aws_route_table.trend_rt.id
}

resource "aws_route_table_association" "trend_rta_2" {
  subnet_id      = aws_subnet.trend_subnet_2.id
  route_table_id = aws_route_table.trend_rt.id
}

# ---------------------------
# Security Group (Jenkins ONLY)
# ---------------------------
resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-sg"
  vpc_id = aws_vpc.trend_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# ---------------------------
# Security Group (EKS Worker Nodes) ✅ NEW
# ---------------------------
resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.trend_vpc.id

  # Kubernetes API Server
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubelet
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node-to-node communication
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-nodes-sg"
  }
}

# ---------------------------
# IAM Role for Jenkins EC2
# ---------------------------
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# ---------------------------
# EC2 Instance (Jenkins)
# ---------------------------
resource "aws_instance" "jenkins" {
  ami                    = "ami-0ff5003538b60d5ec"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.trend_subnet_1.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum install java-17-amazon-corretto jenkins -y
              systemctl start jenkins
              systemctl enable jenkins
              EOF

  tags = {
    Name = "Jenkins-EC2"
  }
}
