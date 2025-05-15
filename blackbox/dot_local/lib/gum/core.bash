# gum/core.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_GUM_CORE" ] && return 0
_GUM_CORE=1

GUM_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

# choose   : Choose an option from a list of choices
. "${GUM_HERE:?}/choose.bash"

# confirm  : Ask a user to confirm an action
. "${GUM_HERE:?}/confirm.bash"

# file     : Pick a file from a folder
. "${GUM_HERE:?}/file.bash"

# filter   : Filter items from a list
. "${GUM_HERE:?}/filter.bash"

# format   : Format a string using a template
. "${GUM_HERE:?}/format.bash"

# input    : Prompt for some input
. "${GUM_HERE:?}/input.bash"

# join     : Join text vertically or horizontally
. "${GUM_HERE:?}/join.bash"

# pager    : Scroll through a file
# spin     : Display spinner while running a command
# style    : Apply coloring, borders, spacing to text
# table    : Render a table of data
# write    : Prompt for long-form text
# log      : Log messages to output
