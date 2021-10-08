variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = <<EOF

  #!/bin/bash

  sudo amazon-linux-extras install ansible2 -y

  aws s3 cp s3://kilp-ansible/httpd.yaml httpd.yaml

  sudo ansible-playbook httpd.yaml

EOF

}

variable "name" {
  description = "EC2 Name."
  type        = string
}

variable "ami" {
  description = "Base AMI to use."
  type        = string
}

variable "instance_type" {
  description = "Instance type."
  type        = string
}

variable "key_name" {
  description = "Key Pair name."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security Group IDs."
  type        = list(string)
}

variable "subnet_id" {
  description = "Subnet ID."
  type        = string
}

variable "iam_instance_profile" {
  description = "EC2 Instance Profile to use."
  type        = string
}
