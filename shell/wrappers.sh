#!/bin/sh source-this-script

# Allow definition of Kubectl aliases by putting an executable "kubectl-foo"
# somewhere in the PATH. Add paging when outputting to the terminal, as kubectl
# output can be long (e.g. kubectl describe pod), and the command (nor my
# extensions) doesn't do that on its own.
kubectl()
{
    typeset -a pager=("${PAGER:-less}" --RAW-CONTROL-CHARS); [ -t 1 ] || pager=()
    typeset kubectlAlias="kubectl-$1"
    if [ $# -eq 0 ]; then
	eval 'kubectl ${KUBECTL_DEFAULT_COMMAND:-p}' "${pager:+|}" '"${pager[@]}"'
    elif type ${BASH_VERSION:+-t} "$kubectlAlias" >/dev/null 2>&1; then
	shift
	eval $kubectlAlias '"$@"' "${pager:+|}" '"${pager[@]}"'
    else
	eval 'command kubectl "$@"' "${pager:+|}" '"${pager[@]}"'
    fi
}
