#!/bin/bash

sudo sudo apt update -y
sudo apt install ansible
sudo apt upgrade -y

ansible-galaxy collection install kubernetes.core
mkdir ~/.kube
touch ~/.kube/config
#microk8s kubectl config view --raw >~/.kube/config
ansible-playbook ~/lab-k8s/ansible/ansible-book.yml
sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube
newgrp microk8s