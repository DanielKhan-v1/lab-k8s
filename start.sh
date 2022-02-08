#!/bin/bash

sudo sudo apt update
sudo apt install ansible
sudo apt upgrade -y

cd ~/lab-k8s/ansible/
ansible-galaxy collection install kubernetes.core
ansible-playbook ansible-book.yml
sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube
newgrp microk8s