#! /bin/bash

sudo apt update 

sudo apt install software-properties-common -y

sudo add-apt-repository --yes --update ppa:ansible/ansible

sudo apt install ansible -y

sudo wget http://kilp-ansible.s3.amazonaws.com/httpd-azure.yaml httpd-azure.yaml

sudo ansible-playbook httpd-azure.yaml 