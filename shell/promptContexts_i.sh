#!/bin/sh source-this-script

_PS1PanelContext_kubectl()
{
    [ -n "$_kubectl_use" ] || return
    sed -ne 's/^current-context: /k8s:/p' "${KUBECONFIG:-${HOME}/.kube/config}" 2>/dev/null
}
