#AWS Variables

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
}

variable "lc_name" {
  description = "Config Name."
  type        = string
}

variable "image_id" {
  description = "Base AMI image to use."
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

variable "asg_name" {
  description = "Name of Auto Scaling Group."
  type        = string
}

#Azure Variables

variable "location" {
  description = "Location to deploy Azure resources."
  type        = string
}