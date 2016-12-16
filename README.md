# kubectl CLI extensions

These are some personal aliases, shortcuts, and extensions that make (my) work with the [Kubernetes](http://kubernetes.io/) command-line utility `kubectl` easier and faster. Some of them may be specific to my environment and workflow, but maybe someone finds a valuable nugget in there.

Use the following (Bash) shell function to invoke the extensions in the same way as the built-in kubectl commands, via `kubectl SUBCOMMAND`:

    # Allow definition of Kubectl aliases putting an executable "kubectl-foo"
    # somewhere in the PATH.
    exists kubectl && kubectl() {
        typeset -r kubectlAlias="kubectl-$1"
        if [ $# -eq 0 ]; then
            kubectl ${KUBECTL_DEFAULT_COMMAND:-get pods}
        elif type -t "$kubectlAlias" >/dev/null; then
            shift
            "$kubectlAlias" "$@"
        else
            "$(which kubectl)" "$@"
        fi
    }
