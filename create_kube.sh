mkdir ~/.kube
touch ~/.kube/config
microk8s kubectl config view --raw >~/.kube/config