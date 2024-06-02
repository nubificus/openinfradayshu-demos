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


pei "sudo nerdctl run --runtime io.containerd.kata-fc.v2 --rm -it --pull always --snapshotter devmapper harbor.nbfc.io/nubificus/vaccel-torch-example:x86_64 ./build/classifier ./cnn_trace.pt ./bert_cased_vocab.txt 1"


pei "sudo nerdctl run --runtime io.containerd.kata-fc-vaccel-torch.v2 --rm -it --pull always --snapshotter devmapper harbor.nbfc.io/nubificus/vaccel-torch-example:x86_64-vaccel ./build/classifier ./cnn_trace.pt ./bert_cased_vocab.txt 0"
