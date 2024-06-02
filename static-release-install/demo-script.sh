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

export YQ_VERSION=3.4.1
export ARCHITECTURE=$(dpkg --print-architecture)
pei "wget -q https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCHITECTURE"
pei "sudo install --mode 755 yq_linux_$ARCHITECTURE /usr/local/bin/yq"
rm yq_linux_$ARCHITECTURE

export NERDCTL_VERSION=0.20.0
pei "wget -q https://github.com/containerd/nerdctl/releases/download/v$NERDCTL_VERSION/nerdctl-$NERDCTL_VERSION-linux-amd64.tar.gz"
pei "sudo tar Cxzvf /usr/local/bin nerdctl-$NERDCTL_VERSION-linux-amd64.tar.gz"
rm nerdctl-0.20.0-linux-amd64.tar.gz

pei "git clone https://github.com/kata-containers/kata-containers"

export CONTAINERD_VERSION=$(yq read kata-containers/versions.yaml externals.containerd.version | sed 's/v//')
export ARCHITECTURE=$(dpkg --print-architecture)
pei "wget -q https://github.com/containerd/containerd/releases/download/v$CONTAINERD_VERSION/containerd-$CONTAINERD_VERSION-linux-$ARCHITECTURE.tar.gz"
pei "sudo tar Cxzvf /usr containerd-$CONTAINERD_VERSION-linux-$ARCHITECTURE.tar.gz"
pei "sudo rm -f containerd-$CONTAINERD_VERSION-linux-$ARCHITECTURE.tar.gz"

pei "wget -q https://raw.githubusercontent.com/containerd/containerd/v$CONTAINERD_VERSION/containerd.service"
pei "sudo rm -f /lib/systemd/system/containerd.service"
pei "sudo mv containerd.service /lib/systemd/system/containerd.service"
pei "sudo sed -i 's|ExecStart=/usr/local/bin/containerd|ExecStart=/usr/bin/containerd|' /lib/systemd/system/containerd.service"
pei "sudo systemctl daemon-reload"
pei "sudo systemctl enable --now containerd"

pei "sudo mkdir -p /etc/containerd"
pei "sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.bak"
pei "containerd config default | sudo tee /etc/containerd/config.toml"
pei "sudo systemctl restart containerd"

export CNI_VERSION=$(yq read kata-containers/versions.yaml externals.cni-plugins.version | sed 's/v//')
export ARCHITECTURE=$(dpkg --print-architecture)
pei "wget -q https://github.com/containernetworking/plugins/releases/download/v$CNI_VERSION/cni-plugins-linux-$ARCHITECTURE-v$CNI_VERSION.tgz"
pei "sudo mkdir -p /opt/cni/bin"
pei "sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-$ARCHITECTURE-v$CNI_VERSION.tgz"
sudo rm -f cni-plugins-linux-$ARCHITECTURE-v$CNI_VERSION.tgz


pei "wget -q --continue https://github.com/kata-containers/kata-containers/releases/download/3.5.0/kata-static-3.5.0-amd64.tar.xz"
#pei "mkdir /tmp/kata"
pei "xzcat kata-static-3.5.0-amd64.tar.xz | sudo tar -xvf - -C /"
#pei "sudo rsync -agoxvPH /tmp/kata/opt/kata/ /opt/kata"


cat <<EOF | sudo tee /usr/local/bin/containerd-shim-kata-rs-v2
#!/bin/bash
KATA_CONF_FILE=/opt/kata/share/defaults/kata-containers/runtime-rs/configuration-dragonball.toml /opt/kata/runtime-rs/bin/containerd-shim-kata-v2 \$@
EOF

#pei "cat /usr/local/bin/containerd-shim-kata-rs-v2"

pei "sudo chmod +x /usr/local/bin/containerd-shim-kata-rs-v2"

cat <<EOF | sudo tee /usr/local/bin/containerd-shim-kata-qemu-v2
#!/bin/bash
KATA_CONF_FILE=/opt/kata/share/defaults/kata-containers/configuration-qemu.toml /opt/kata/bin/containerd-shim-kata-v2 \$@
EOF

#pei "cat /usr/local/bin/containerd-shim-kata-qemu-v2"
pei "sudo chmod +x /usr/local/bin/containerd-shim-kata-qemu-v2"

cat <<EOF | sudo tee /usr/local/bin/containerd-shim-kata-fc-v2
#!/bin/bash
KATA_CONF_FILE=/opt/kata/share/defaults/kata-containers/configuration-fc.toml /opt/kata/bin/containerd-shim-kata-v2 \$@
EOF

#pei "cat /usr/local/bin/containerd-shim-kata-fc-v2"
pei "sudo chmod +x /usr/local/bin/containerd-shim-kata-fc-v2"

#cmd

