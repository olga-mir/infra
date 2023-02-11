#!/bin/bash

# This script installs various tools for work and experimentation.
# Currently run manually after VM is up, at a later stage I'll build and use AMI when I get a reasonable base sorted

sudo yum update -y

sudo yum install -y docker
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker ssm-user

sudo yum install -y kernel-headers-$(uname -r | cut -d'.' -f1-5)
sudo yum install -y kernel-devel-$(uname -r | cut -d'.' -f1-5)
sudo yum install -y bcc bpftool

sudo yum install -y httpd-tools # ab
