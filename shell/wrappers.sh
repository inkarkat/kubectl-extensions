#!/bin/sh source-this-script

# Allow definition of Kubectl aliases by putting an executable "kubectl-foo"
# somewhere in the PATH.
kubectl()
{
    typeset kubectlAlias="kubectl-$1"
    if [ $# -eq 0 ]; then
	kubectl ${KUBECTL_DEFAULT_COMMAND:-p}
    elif type ${BASH_VERSION:+-t} "$kubectlAlias" >/dev/null 2>&1; then
	shift
	eval $kubectlAlias '"$@"'
    else
	command kubectl "$@"
    fi
}
