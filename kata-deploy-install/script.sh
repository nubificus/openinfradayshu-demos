#!/usr/bin/env bash

export POD_CIDR="10.244.32.0/19"
export SERVICE_CIDR="10.244.0.0/19"

# Install K3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--flannel-backend=none ' sh -s -   --disable-network-policy   --disable "servicelb"      --disable "metrics-server" --cluster-cidr $POD_CIDR --service-cidr $SERVICE_CIDR

# Copy config file & set the env var
mkdir $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
sudo chown -R ubuntu $HOME/.kube/

# Inspect Pods (should be Pending or nothing)
kubectl get pods -o wide -A

# Install calico CNI (taking into account the POD_CIDR from above)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml
sed -i.bak "s|192\.168\.0\.0/16|${POD_CIDR}|g" custom-resources.yaml
kubectl apply -f custom-resources.yaml

# Pull image (overlap with the time calico initializes)
sudo ctr -n k8s.io image pull quay.io/kata-containers/kata-deploy:latest 2>&1 > /dev/null

# Inspect pods (should be ContainerCreating / Running / Complete)
kubectl get pods -o wide -A

# Get kata-containers code repo (for the manifests)
git clone https://github.com/kata-containers/kata-containers.git
cd kata-containers/tools/packaging/kata-deploy
kubectl apply -f kata-rbac/base/kata-rbac.yaml
kubectl apply -k kata-deploy/overlays/k3s

# Inspect the kata-deploy pod
kubectl get pods -n kube-system -o wide -l name=kata-deploy

# Get the nginx container image (again, overlap, while kata-deploy installs the release)
sudo ctr -n k8s.io image pull docker.io/library/nginx:1.14 2>&1 > /dev/null

# Inspect kata-deploy Pod
kubectl logs -n kube-system -l name=kata-deploy


# Add kata runtimeclasses to k3s
kubectl apply -f https://raw.githubusercontent.com/kata-containers/kata-containers/main/tools/packaging/kata-deploy/runtimeclasses/kata-runtimeClasses.yaml

# Inspect example deployments
ls -la examples/

cat examples/nginx-deployment-qemu.yaml

# Spawn a kata-qemu nginx
kubectl apply -f examples/nginx-deployment-qemu.yaml

# Inspect Pods
kubectl get pods -o wide

# Inspect processes (see the qemu command)
ps -ef |grep qemu

# Spawn a kata-dragonball / runtime-rs nginx
kubectl apply -f examples/nginx-deployment-dragonball.yaml

# Inspect Pods
kubectl get pods -o wide

# Inspect merged runtime & hypervisor
ps -ef |grep runtime-rs
