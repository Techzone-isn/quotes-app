# Create a custom VPC with the name "myVPC"
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
#
resource "tls_private_key" "app_ssh_key" {
 algorithm = "RSA"
 rsa_bits = 4096
}

resource "aws_key_pair" "app_ssh_key" {
 key_name   = "app_ssh_key"
 public_key = tls_private_key.app_ssh_key.public_key_openssh
}
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"  # Change this to your desired CIDR block

  tags = {
    Name = "myVPC03"
  }
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"  # Change this to your desired CIDR bl                               ock for the public subnet
  map_public_ip_on_launch = true           # Associate public IP addresses with                                instances in this subnet
}


# Create a default route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Default route for all traffic
    gateway_id = aws_internet_gateway.custom_igw.id
  }
}

# Associate the default route table with the public subnet
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a security group to allow SSH access (you can customize the ingress rul                               es as needed)
resource "aws_security_group" "custom_sg" {
  name        = "custom-security-group"
  description = "Allow SSH and other necessary ports"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }

  # Add more ingress rules if required for your application
}

# Launch the EC2 instance in the public subnet and attach the security group
resource "aws_instance" "custom_ec2_instance" {
  #ami           = "ami-0a1179631ec8933d7"
   ami           = "ami-0e001c9271cf7f3b9"

  instance_type = "t2.medium"
  tags = {
    Name = "Qoute-Server"
  }
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.custom_sg.id]

  associate_public_ip_address = true  # Assign a public IP to the instance

  key_name = aws_key_pair.app_ssh_key.key_name


  # Add additional configuration for the EC2 instance if required (e.g., user_da                               ta, tags, etc.)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apt-transport-https ca-certificates curl software                               -properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg                                --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/                               keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(                               lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/n                               ull
              sudo apt update -y
              sudo apt install docker-ce -y

              # Start Docker service
              sudo systemctl start docker
              # Enable Docker service to start on boot
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu && newgrp docker
              # Install Minikube
              curl -Lo minikube https://storage.googleapis.com/minikube/releases                               /latest/minikube-linux-amd64 \
              && chmod +x minikube
              sudo mv minikube /usr/local/bin/
              sudo yum install git -y
              #sudo apt  install docker.io
              #sudo usermod -aG docker $USER
              #newgrp docker
              git clone https://github.com/Techzone-isn/quotes-app.git
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io                               /release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              sudo mv ./kubectl /usr/local/bin/
              EOF
}

# Output the provide you information if you need any
output "public_ip" {
  value = aws_instance.custom_ec2_instance.public_ip
}
output "VPC_ID" {
  value = aws_vpc.custom_vpc.id
}
output "Public_Subnet" {
  value = aws_subnet.public_subnet.id
}
output "private_key_pem" {
value     = tls_private_key.app_ssh_key.private_key_pem
sensitive = true
}
