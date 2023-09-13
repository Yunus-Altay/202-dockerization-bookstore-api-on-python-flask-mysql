terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# change the token
provider "github" {
  token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

resource "github_repository" "myrepo" {
  name       = "bookstore-api-repo"
  visibility = "private"
  auto_init  = true
}

resource "github_branch_default" "main" {
  branch     = "main"
  repository = github_repository.myrepo.name
}

variable "files" {
  default = ["bookstore-api.py", "Dockerfile", "docker-compose.yaml", "requirements.txt"]
}

resource "github_repository_file" "app-files" {
  for_each            = toset(var.files)
  content             = file(each.value)
  file                = each.value
  repository          = github_repository.myrepo.name
  branch              = "main"
  commit_message      = "docker files transferred by terraform"
  overwrite_on_create = true
}

locals {
  secgr-dynamic-ports = [22, 80]
}

resource "aws_security_group" "docker_instance_sec_gr" {
  name = "Docker instance security group with SSH, HTTP and HTTPS ports"

  tags = {
    Name = "Bookstore web server security group"
  }

  dynamic "ingress" {
    for_each = local.secgr-dynamic-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "docker_instance" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t2.micro"
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.docker_instance_sec_gr.id]
  tags = {
    Name = "Web Server of Bookstore"
  }
  user_data = base64encode(templatefile("user-data.sh", { db_password = var.db_password, db_root_password = var.db_root_password }))

  depends_on = [github_repository.myrepo, github_repository_file.app-files]
}

variable "key-name" {
  default = "first-key-pair"
}

variable "db_password" {
  default = "simaox1234"
}

variable "db_root_password" {
  default = "admin1234"
}