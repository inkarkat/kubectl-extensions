#!/bin/bash source-this-script

# kc			kubectl
# kca			kubectl --all-namespaces
# kcc			kubectl --namespace core
# kc1			kubectl --namespace opsbridge1
# kc1-set-ns, kc1-get-ns
# kc2			kubectl --namespace opsbridge2
# kc2-set-ns, kc2-get-ns
# kco			kubectl --namespace $(kubectl-ns opsbridge-*)
# kco-set-ns, kco-get-ns
# kci			kubectl --namespace ingo
# kci-set-ns, kci-get-ns
# kc-rehash-ns		After you've done kc*-set-ns in a different shell.
kc()
{
    typeset -r kcAlias="kubectl-$1"
    if type ${BASH_VERSION:+-t} "$kcAlias" >/dev/null 2>&1; then
	shift
	eval $kcAlias '"$@"'
	return
    fi

    [ $# -eq 0 ] && set -- "${KUBECTL_DEFAULT_COMMAND:-p}"

    kubectl "$@"
}

kca()
{
    typeset -r kcaAlias="kca-$1"
    if type ${BASH_VERSION:+-t} "$kcaAlias" >/dev/null 2>&1; then
	shift
	eval $kcaAlias '"$@"'
	return
    fi

    [ $# -eq 0 ] && set -- "${KUBECTL_DEFAULT_COMMAND:-p}"
    typeset -a subCommand=()
    while [ "$1" ] && [ "${1:0:1}" != '-' ]
    do
	subCommand+=("$1")
	shift
    done

    kubectl "${subCommand[@]}" --all-namespaces "$@"
}
kcc()
{
    typeset -r kccAlias="kcc-$1"
    if type ${BASH_VERSION:+-t} "$kccAlias" >/dev/null 2>&1; then
	shift
	eval $kccAlias '"$@"'
	return
    fi

    [ $# -eq 0 ] && set -- "${KUBECTL_DEFAULT_COMMAND:-p}"
    typeset -a subCommand=()
    while [ "$1" ] && [ "${1:0:1}" != '-' ]
    do
	subCommand+=("$1")
	shift
    done

    kubectl "${subCommand[@]}" --namespace core "$@"
}
kc1()
{
    typeset -r kc1Alias="kc1-$1"
    if type ${BASH_VERSION:+-t} "$kc1Alias" >/dev/null 2>&1; then
	shift
	eval $kc1Alias '"$@"'
	return
    fi

    [ $# -eq 0 ] && set -- "${KUBECTL_DEFAULT_COMMAND:-p}"
    typeset -a subCommand=()
    while [ "$1" ] && [ "${1:0:1}" != '-' ]
    do
	subCommand+=("$1")
	shift
    done

    kubectl "${subCommand[@]}" --namespace "${KC1_NAMESPACE:-opsbridge1}" "$@"
}
kc2()
{
    typeset -r kc2Alias="kc2-$1"
    if type ${BASH_VERSION:+-t} "$kc2Alias" >/dev/null 2>&1; then
	shift
	eval $kc2Alias '"$@"'
	return
    fi

    [ $# -eq 0 ] && set -- "${KUBECTL_DEFAULT_COMMAND:-p}"
    typeset -a subCommand=()
    while [ "$1" ] && [ "${1:0:1}" != '-' ]
    do
	subCommand+=("$1")
	shift
    done

    kubectl "${subCommand[@]}" --namespace "${KC2_NAMESPACE:-opsbridge2}" "$@"
}
kco()
{
    typeset -r kcoAlias="kco-$1"
    if type ${BASH_VERSION:+-t} "$kcoAlias" >/dev/null 2>&1; then
	shift
	eval $kcoAlias '"$@"'
	return
    fi

    [ $# -eq 0 ] && set -- "${KUBECTL_DEFAULT_COMMAND:-p}"
    typeset -a subCommand=()
    while [ "$1" ] && [ "${1:0:1}" != '-' ]
    do
	subCommand+=("$1")
	shift
    done

    if [ -n "$KCO_NAMESPACE" ]; then
	typeset -a namespaces=("$KCO_NAMESPACE")
    else
	local IFS=$'\n'
	typeset -a namespaces=($(kubectl-ns '^opsbridge-'))
	case ${#namespaces[@]} in
	    0)	echo >&2 "ERROR: No matching namespace found."; return 1;;
	    1)	;;
	    *)	local IFS=' '; printf >&2 'ERROR: Multiple namespaces match: %s\n' "${namespaces[*]}"; return 1;;
	esac
    fi
    kubectl "${subCommand[@]}" --namespace "${namespaces[0]}" "$@"
}
kci()
{
    typeset -r kciAlias="kci-$1"
    if type ${BASH_VERSION:+-t} "$kciAlias" >/dev/null 2>&1; then
	shift
	eval $kciAlias '"$@"'
	return
    fi

    [ $# -eq 0 ] && set -- "${KUBECTL_DEFAULT_COMMAND:-p}"
    typeset -a subCommand=()
    while [ "$1" ] && [ "${1:0:1}" != '-' ]
    do
	subCommand+=("$1")
	shift
    done

    kubectl "${subCommand[@]}" --namespace "${KCI_NAMESPACE:-ingo}" "$@"
}
alias kc1-set-ns='eval "$(kc-set-ns KC1_NAMESPACE)"'
alias kc2-set-ns='eval "$(kc-set-ns KC2_NAMESPACE)"'
alias kco-set-ns='eval "$(kc-set-ns KCO_NAMESPACE)"'
alias kci-set-ns='eval "$(kc-set-ns KCI_NAMESPACE)"'

alias kc1-get-ns='echo "kc1 is using namespace ${KC1_NAMESPACE:-opsbridge1}"'
alias kc2-get-ns='echo "kc2 is using namespace ${KC1_NAMESPACE:-opsbridge2}"'
alias kco-get-ns='echo "kco is using namespace ${KCO_NAMESPACE:-^opsbridge-}"'
alias kci-get-ns='echo "kci is using namespace ${KCI_NAMESPACE:-ingo}"'

alias kc-rehash-ns='. ~/.local/autosource/kubectl-opsbridge-namespaces.sh'


# Completion for my kubectl extensions.
_kubectlWrapper()
{
    # The "kcx" variant needs to be replaced with the expanded "kubectl -n
    # X" arguments, and all relevant Bash completion variables updated
    # accordingly.
    local kubectlVariantName="${kubectlVariant[0]}"
    typeset -a kubectlVariantArgs=("${kubectlVariant[@]:1}")
    local kubectlVariantString="kubectl ${kubectlVariantArgs[*]}"

    COMP_LINE="kubectl${kubectlVariantArgs:+ }${kubectlVariantArgs[@]}${COMP_LINE#${kubectlVariantName}}"
    COMP_WORDS=(kubectl "${kubectlVariantArgs[@]}" "${COMP_WORDS[@]:1}")
    let COMP_CWORD+=${#kubectlVariantArgs[@]}
    let COMP_POINT+=${#kubectlVariantString}-${#kubectlVariantName}

    __start_kubectl kubectl "${@:2}"
}
_kubectlExtensionSubcommands()
{
    local kubectlVariantName="${kubectlVariant[0]}"
    # Need to do this before _kubectlWrapper adapts the Bash completion
    # variables.
    typeset -a kubectlExtensionSubcommands; readarray -t kubectlExtensionSubcommands < <(compgen -c | sed -n \
	-e "/^kubectl-${COMP_WORDS[1]}/s/^kubectl-//p" \
	-e "/^${kubectlVariantName}-${COMP_WORDS[1]}/s/^${kubectlVariantName}-//p" \
    )

    _kubectlWrapper "$@"
    COMPREPLY+=("${kubectlExtensionSubcommands[@]}")
}

# Completion for my custom variants with automatic (namespace) arguments
# added.
_kubectlVariantWrapper()
{
    if [ ${#COMP_WORDS[@]} -eq 2 ]; then
	_kubectlExtensionSubcommands "$@"
    else
	_kubectlWrapper "$@"
    fi
}

_kc() { typeset -a kubectlVariant=(kc); _kubectlVariantWrapper "$@"; }
complete -o default -F _kc kc

_kca() { typeset -a kubectlVariant=(kca --all-namespaces); _kubectlVariantWrapper "$@"; }
complete -o default -F _kca kca
_kcc() { typeset -a kubectlVariant=(kcc -n core); _kubectlVariantWrapper "$@"; }
complete -o default -F _kcc kcc
_kc1() { typeset -a kubectlVariant=(kc1 -n "${KC1_NAMESPACE:-opsbridge1}"); _kubectlVariantWrapper "$@"; }
complete -o default -F _kc1 kc1
_kc2() { typeset -a kubectlVariant=(kc2 -n "${KC2_NAMESPACE:-opsbridge2}"); _kubectlVariantWrapper "$@"; }
complete -o default -F _kc2 kc2
_kco() { typeset -a kubectlVariant=(kco -n "$(kubectl-ns "${KCO_NAMESPACE:-^opsbridge-}")"); _kubectlVariantWrapper "$@"; }
complete -o default -F _kco kco
_kci() { typeset -a kubectlVariant=(kci -n "${KCI_NAMESPACE:-ingo}"); _kubectlVariantWrapper "$@"; }
complete -o default -F _kci kci
