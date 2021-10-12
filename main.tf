terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.name

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = false
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
  user_data              = var.user_data
  iam_instance_profile   = var.iam_instance_profile

  tags = {
    DeployedBy  = "Terraform Cloud"
    Environment = "dev"
  }
}    

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "kilp-ansible"
  key    = "httpd.yaml"
  source = "${path.module}/Ansible/httpd.yaml"
  etag   = "${filemd5("${path.module}/Ansible/httpd.yaml")}"
}