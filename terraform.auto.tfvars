#AWS Variables

lc_name       = "terraform-demo-lc"
image_id      = "ami-087c17d1fe0178315"
instance_type = "t2.micro"
key_name      = "Test"
asg_name      = "terraform-demo-asg"
user_data     = <<EOF

  #!/bin/bash

  sudo amazon-linux-extras install ansible2 -y

  wget http://kilp-ansible.s3.amazonaws.com/httpd-aws.yaml httpd-aws.yaml

  sudo ansible-playbook httpd-aws.yaml

EOF

#Azure Variables

location = "West Europe"
vmss_password = "${env.VMSS_PASS}"
