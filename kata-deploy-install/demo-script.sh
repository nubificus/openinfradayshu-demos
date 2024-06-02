#!/usr/bin/env bash

#################################
# include the -=magic=-
# you can pass command line args
#
# example:
# to disable simulated typing
# . ../demo-magic.sh -d
#
# pass -h to see all options
#################################
. ../demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=40

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W $ ${COLOR_RESET}"

# text color
# DEMO_CMD_COLOR=$BLACK

# hide the evidence
clear

# put your demo awesomeness here

export POD_CIDR="10.244.32.0/19"
export SERVICE_CIDR="10.244.0.0/19"

pei "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--flannel-backend=none ' sh -s -   --disable-network-policy   --disable \"servicelb\"      --disable \"metrics-server\" --cluster-cidr $POD_CIDR --service-cidr $SERVICE_CIDR"

pei "mkdir $HOME/.kube"
pei "sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config"
pei "export KUBECONFIG=$HOME/.kube/config"
pei "sudo chown -R ubuntu $HOME/.kube/"

PROMPT_TIMEOUT=2
wait

pei "kubectl get pods -o wide -A"

pei "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml"
pei "wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml"
pei "sed -i.bak \"s|192\.168\.0\.0/16|${POD_CIDR}|g\" custom-resources.yaml"
pei "kubectl apply -f custom-resources.yaml"

#pei "kubectl get pods -o wide -A"

sudo ctr -n k8s.io image pull quay.io/kata-containers/kata-deploy:latest 2>&1 > /dev/null

PROMPT_TIMEOUT=50
wait

pei "kubectl get pods -o wide -A"

pei "git clone https://github.com/kata-containers/kata-containers.git"
pei "cd kata-containers/tools/packaging/kata-deploy"
pei "kubectl apply -f kata-rbac/base/kata-rbac.yaml"
pei "kubectl apply -k kata-deploy/overlays/k3s"

pei "kubectl get pods -n kube-system -o wide -l name=kata-deploy"

sudo ctr -n k8s.io image pull docker.io/library/nginx:1.14 2>&1 > /dev/null

PROMPT_TIMEOUT=30
wait

pei "kubectl logs -n kube-system -l name=kata-deploy"


pei "kubectl apply -f https://raw.githubusercontent.com/kata-containers/kata-containers/main/tools/packaging/kata-deploy/runtimeclasses/kata-runtimeClasses.yaml"
pei "ls -la examples/"


pei "cat examples/nginx-deployment-qemu.yaml"
PROMPT_TIMEOUT=20
wait

pei "kubectl apply -f examples/nginx-deployment-qemu.yaml"
pei "kubectl get pods -o wide"
pei "ps -ef |grep qemu"

PROMPT_TIMEOUT=15
wait

pei "kubectl apply -f examples/nginx-deployment-dragonball.yaml"

pei "kubectl get pods -o wide"

PROMPT_TIMEOUT=5
wait

pei "kubectl get pods -o wide"
pei "ps -ef |grep runtime-rs"
