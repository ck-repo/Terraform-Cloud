name                   = "terraform-cloud-test"
ami                    = "ami-087c17d1fe0178315"
instance_type          = "t2.micro"
key_name               = "Test"
vpc_security_group_ids = ["sg-0a1a3a4a"]
subnet_id              = "subnet-1138155b"
iam_instance_profile   = "ansible_s3"