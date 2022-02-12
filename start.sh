#!/bin/bash

sudo mkfs -t ext4 /dev/nvme1n1
sudo mount /dev/nvme1n1 /mnt/ebs
sudo su
echo "/dev/nvme1n1  /mnt/ebs  ext4  defaults,nofail  0  2" >> /etc/fstab
exit

sudo sudo apt update -y
sudo apt install ansible
sudo apt upgrade -y

ansible-galaxy collection install kubernetes.core
ansible-playbook ~/lab-k8s/ansible/ansible-book.yml
sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube
newgrp microk8s