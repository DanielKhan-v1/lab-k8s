#!/bin/bash

sudo sudo apt update -y
sudo apt install ansible
sudo apt upgrade -y

cd ~/lab-k8s/ansible/
ansible-galaxy collection install kubernetes.core
microk8s kubectl config view --raw >~/.kube/config
ansible-playbook ansible-book.yml
sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube
newgrp microk8s