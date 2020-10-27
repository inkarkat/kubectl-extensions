# kubectl CLI extensions

_ Additions and tweaks to the kubectl CLI._

These are some personal aliases, shortcuts, and extensions that make (my) work with the [Kubernetes](http://kubernetes.io/) command-line utility `kubectl` easier and faster. Some of them may be specific to my environment and workflow, but maybe someone finds a valuable nugget in there.

### Installation

Download all / some selected extensions (note that some have dependencies, though) and put them somewhere in your `PATH`. You can then invoke them via `kubectl-SUBCOMMAND`.

It is recommended to also use the (Bash, but should also work in Korn shell and Dash) shell functions (e.g. in your `.bashrc`) found at [shell/wrappers.sh](shell/wrappers.sh) to transparently invoke the extensions in the same way as the built-in Kubernetes commands, via `kubectl SUBCOMMAND`.

Note that [Kubernetes also provides its own extension mechanism](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/); these need to provide a YAML plugin descriptor, get command-line arguments already parsed, and are invoked through `kubectl plugin PLUGIN-COMMAND`. I don't intend to convert mine into that format, because parsing effort is minimal, and I prefer to seamlessly blend in with (or even override) built-in subcommands.
