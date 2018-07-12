# kubectl CLI extensions

These are some personal aliases, shortcuts, and extensions that make (my) work with the [Kubernetes](http://kubernetes.io/) command-line utility `kubectl` easier and faster. Some of them may be specific to my environment and workflow, but maybe someone finds a valuable nugget in there.

### Installation

Download all / some selected extensions (note that some have dependencies, though) and put them somewhere in your `PATH`. You can then invoke them via `kubectl-SUBCOMMAND`.

Optionally, use the following (Bash) shell function (e.g. in your `.bashrc`) to transparently invoke the extensions in the same way as the built-in kubectl commands, via `kubectl SUBCOMMAND`:

    # Allow definition of Kubectl aliases putting an executable "kubectl-foo"
    # somewhere in the PATH.
    kubectl() {
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
