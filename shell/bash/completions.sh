#!/bin/bash source-this-script

# Completion for kubectl itself; it uses a non-standard approach (not
# /etc/bash_completion.d/).
source <(kubectl completion bash)
