#!/usr/bin/env bash


# Install YQ
export YQ_VERSION=3.4.1
export ARCHITECTURE=$(dpkg --print-architecture)
wget -q https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCHITECTURE
sudo install --mode 755 yq_linux_$ARCHITECTURE /usr/local/bin/yq
rm yq_linux_$ARCHITECTURE

# Install nerdctl
export NERDCTL_VERSION=0.20.0
wget -q https://github.com/containerd/nerdctl/releases/download/v$NERDCTL_VERSION/nerdctl-$NERDCTL_VERSION-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local/bin nerdctl-$NERDCTL_VERSION-linux-amd64.tar.gz
rm nerdctl-0.20.0-linux-amd64.tar.gz


# Get the kata-containers code (for versions.yaml)
git clone https://github.com/kata-containers/kata-containers


# Install containerd
export CONTAINERD_VERSION=$(yq read kata-containers/versions.yaml externals.containerd.version | sed 's/v//')
export ARCHITECTURE=$(dpkg --print-architecture)
wget -q https://github.com/containerd/containerd/releases/download/v$CONTAINERD_VERSION/containerd-$CONTAINERD_VERSION-linux-$ARCHITECTURE.tar.gz
sudo tar Cxzvf /usr containerd-$CONTAINERD_VERSION-linux-$ARCHITECTURE.tar.gz
sudo rm -f containerd-$CONTAINERD_VERSION-linux-$ARCHITECTURE.tar.gz

# Setup containerd to work on reboot
wget -q https://raw.githubusercontent.com/containerd/containerd/v$CONTAINERD_VERSION/containerd.service
sudo rm -f /lib/systemd/system/containerd.service
sudo mv containerd.service /lib/systemd/system/containerd.service
sudo sed -i 's|ExecStart=/usr/local/bin/containerd|ExecStart=/usr/bin/containerd|' /lib/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.bak
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

# Install CNI
export CNI_VERSION=$(yq read kata-containers/versions.yaml externals.cni-plugins.version | sed 's/v//')
export ARCHITECTURE=$(dpkg --print-architecture)
wget -q https://github.com/containernetworking/plugins/releases/download/v$CNI_VERSION/cni-plugins-linux-$ARCHITECTURE-v$CNI_VERSION.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-$ARCHITECTURE-v$CNI_VERSION.tgz
sudo rm -f cni-plugins-linux-$ARCHITECTURE-v$CNI_VERSION.tgz

# Get the kata static release from Github
wget -q --continue https://github.com/kata-containers/kata-containers/releases/download/3.5.0/kata-static-3.5.0-amd64.tar.xz

# Install it on /opt/kata
xzcat kata-static-3.5.0-amd64.tar.xz | sudo tar -xvf - -C /

# Install helper wrappers for a multi-hypervisor setup
cat <<EOF | sudo tee /usr/local/bin/containerd-shim-kata-rs-v2
#!/bin/bash
KATA_CONF_FILE=/opt/kata/share/defaults/kata-containers/runtime-rs/configuration-dragonball.toml /opt/kata/runtime-rs/bin/containerd-shim-kata-v2 \$@
EOF

sudo chmod +x /usr/local/bin/containerd-shim-kata-rs-v2

cat <<EOF | sudo tee /usr/local/bin/containerd-shim-kata-qemu-v2
#!/bin/bash
KATA_CONF_FILE=/opt/kata/share/defaults/kata-containers/configuration-qemu.toml /opt/kata/bin/containerd-shim-kata-v2 \$@
EOF

sudo chmod +x /usr/local/bin/containerd-shim-kata-qemu-v2

cat <<EOF | sudo tee /usr/local/bin/containerd-shim-kata-fc-v2
#!/bin/bash
KATA_CONF_FILE=/opt/kata/share/defaults/kata-containers/configuration-fc.toml /opt/kata/bin/containerd-shim-kata-v2 \$@
EOF

sudo chmod +x /usr/local/bin/containerd-shim-kata-fc-v2

# Example spawn of ubuntu:latest containers
# sudo nerdctl run --runtime io.containerd.kata-qemu.v2 --rm -it ubuntu:latest uname -a
# sudo nerdctl run --runtime io.containerd.kata-rs.v2 --rm -it ubuntu:latest uname -a
# sudo nerdctl run --runtime io.containerd.kata-rs.v2 --rm -it ubuntu:latest /bin/bash

# Enable debug console for QEMU & rerun

# sudo nerdctl run --runtime io.containerd.kata-rs.v2 --rm -it ubuntu:latest /bin/bash
# sudo /opt/kata/bin/kata-runtime exec CID
 
