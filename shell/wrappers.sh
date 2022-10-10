#!/bin/bash source-this-script

[ "${BASH_VERSION:-}" -o "${KSH_VERSION:-}" ] || return

# Allow definition of Kubectl aliases by putting an executable "kubectl-foo"
# somewhere in the PATH. Add paging when outputting to the terminal, as kubectl
# output can be long (e.g. kubectl describe pod), and the command (nor my
# extensions) doesn't do that on its own.
kubectl()
{
    let _kubectl_use+=1
    typeset returnKubectlStatus=; [ "${BASH_VERSION:-}" ] && returnKubectlStatus='return ${PIPESTATUS[0]}'
    typeset -a pager=("${PAGER:-less}" --RAW-CONTROL-CHARS); [ -t 1 ] || pager=()

    typeset -a kubectlArgs=()
    while [ $# -ne 0 ]
    do
	case "$1" in
	    --all-namespaces|-A)
			kubectlArgs+=("$1"); shift;;
	    --namespace|-n|--selector|-l|--cluster|--context|--template)
			kubectlArgs+=("$1" "$2"); shift; shift;;
	    --)		break;;
	    *)		break;;
	esac
    done

    typeset kubectlAlias="kubectl-$1"
    if [ ${#kubectlArgs[@]} -eq 0 -a $# -eq 0 ]; then
	eval 'kubectl ${KUBECTL_DEFAULT_COMMAND:-p}' "${pager:+|}" '"${pager[@]}"' "${pager:+; $returnKubectlStatus}"
    elif type ${BASH_VERSION:+-t} "$kubectlAlias" >/dev/null 2>&1; then
	shift
	[ "$kubectlAlias" = kubectl-bash ] && pager=()	# Paging would interfere with the interactive REPL; turn it off.
	[ "$kubectlAlias" = kubectl-ef ] && pager=()	# Paging would interfere with watching for changes in requested objects; turn it off.
	[ "$kubectlAlias" = kubectl-get ] && containsGlob '-w|--watch|--watch-only' "$@" && pager=()  # Paging would interfere with watching for changes in requested objects; turn it off.

	eval $kubectlAlias '"${kubectlArgs[@]}" "$@"' "${pager:+|}" '"${pager[@]}"' "${pager:+; $returnKubectlStatus}"
    else
	contains logs "$@" && contains -f "$@" && pager=()  # Paging would interfere with log following; turn it off.
	contains get "$@" && containsGlob '-w|--watch|--watch-only' "$@" && pager=()  # Paging would interfere with watching for changes in requested objects; turn it off.
	contains edit "$@" && pager=()  # Paging would interfere with interactive editing; turn it off.

	eval 'command kubectl "${kubectlArgs[@]}" "$@"' "${pager:+|}" '"${pager[@]}"' "${pager:+; $returnKubectlStatus}"
    fi
}
