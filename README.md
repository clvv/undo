% UNDO(1) undo user manual
% Wei Dai <x@wei23.net>
% Jul 08, 2012

# NAME

undo - undo commands

# SYNOPSIS

undo [-i|-p] command [arguments ...]

    -i   confirm before executing
    -p   only print the reverse command

# DESCRIPTION

Undo generates and executes reverse commands according to the command passed
in.

# EXAMPLES

    # 1. With help from history substitution
    undo !!
    undo !-2
    undo -i !tar

    # 2. With help from command history
    # Use your favorite way to navigate to the target command
    # Insert "undo" in front of the target command
    # Hit enter

# NOTES

Undo supports or partially supports the following commands:

    cp mv mkdir rmdir tar git gzip gunzip

Undo must be called in the same directory the target command was executed.

Undo *does not* and *cannot* access your shell command history. You should use
history functionalities provided by your shell to pass the target command to
undo.

Undo sources undo recipes from "/etc/undo_recipes" or "$HOME/undo_recipes" if
found.

Undo is alpha software, it is suggested that you use the below alias:

    alias undo='undo -i'

# CONTRIBUTING

Undo is hosted on GitHub: https://github.com/clvv/undo

# COPYING

Undo is licensed under the "MIT/X11" license.

