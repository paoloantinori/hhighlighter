#!/bin/bash


# DESCRIPTION:
#   * h highlights with color specified keywords when you invoke it via pipe
#   * h is just a tiny wrapper around the powerful 'ack' (or 'ack-grep'). you need 'ack' installed to use h. ack website: http://beyondgrep.com/
# INSTALL:
#   * put something like this in your .bashrc:
#     . /path/to/h.sh
#   * or just copy and paste the function in your .bashrc
# TEST ME:
#   * try to invoke:
#     echo "abcdefghijklmnopqrstuvxywz" | h   a b c d e f g h i j k l
# CONFIGURATION:
#   * you can alter the color and style of the highlighted tokens setting values to these 2 environment values following "Perl's Term::ANSIColor" supported syntax
#   * ex.
#     export H_COLORS_FG="bold black on_rgb520","bold red on_rgb025"
#     export H_COLORS_BG="underline bold rgb520","underline bold rgb025"
#     echo abcdefghi | h   a b c d
# GITHUB
#   * https://github.com/paoloantinori/hhighlighter

# Check for the ack command



h() {

    _usage() {
        echo "usage: YOUR_COMMAND | h [-idn] args...
    -i : ignore case
    -d : disable regexp
    -n : invert colors"
    }

    local _OPTS

    # detect pipe or tty
    if [[ -t 0 ]]; then
        _usage
        return
    fi

    # manage flags
    while getopts ":idnQ" opt; do
        case $opt in
            i) _OPTS+=" -i " ;;
            d)  _OPTS+=" -Q " ;;
            n) n_flag=true ;;
            Q)  _OPTS+=" -Q " ;;
                # let's keep hidden compatibility with -Q for original ack users
            \?) _usage
                return ;;
        esac
    done

    shift $(($OPTIND - 1))

    # set zsh compatibility
    [[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays && setopt ignorebraces

    local _i=0

    if [[ -n $H_COLORS_FG ]]; then
        local _CSV="$H_COLORS_FG"
        local OLD_IFS="$IFS"
        IFS=','
        local _COLORS_FG=()
        for entry in $_CSV; do
          _COLORS_FG=("${_COLORS_FG[@]}" "$entry")
        done
        IFS="$OLD_IFS"
    else
        _COLORS_FG=( 
                "underline bold red" \
                "underline bold green" \
                "underline bold yellow" \
                "underline bold blue" \
                "underline bold magenta" \
                "underline bold cyan"
                )
    fi

    if [[ -n $H_COLORS_BG ]]; then
        local _CSV="$H_COLORS_BG"
        local OLD_IFS="$IFS"
        IFS=','
        local _COLORS_BG=()
        for entry in $_CSV; do
          _COLORS_BG=("${_COLORS_BG[@]}" "$entry")
        done
        IFS="$OLD_IFS"
    else
        _COLORS_BG=(            
                "bold on_red" \
                "bold on_green" \
                "bold black on_yellow" \
                "bold on_blue" \
                "bold on_magenta" \
                "bold on_cyan" \
                "bold black on_white"
                )
    fi

    if [[ -z $n_flag ]]; then
        #inverted-colors-last scheme
        _COLORS=("${_COLORS_FG[@]}" "${_COLORS_BG[@]}")
    else
        #inverted-colors-first scheme
        _COLORS=("${_COLORS_BG[@]}" "${_COLORS_FG[@]}")
    fi

    if [[ "$#" -gt ${#_COLORS[@]} ]]; then
        echo "You have passed to hhighlighter more keywords to search than the number of configured colors.
Check the content of your H_COLORS_FG and H_COLORS_BG environment variables or unset them to use default 12 defined colors."
        return 1
    fi

    if [ -n "$ZSH_VERSION" ]; then
       local WHICH="whence"
    else [ -n "$BASH_VERSION" ]
       local WHICH="type -P"
    fi

    if ! ACKGREP_LOC="$($WHICH ack-grep)" || [ -z "$ACKGREP_LOC" ]; then
        if ! ACK_LOC="$($WHICH ack)" || [ -z "$ACK_LOC" ]; then
            echo "ERROR: Could not find the ack or ack-grep commands"
            return 1
        else
            local ACK=$($WHICH ack)
        fi
    else
        local ACK=$($WHICH ack-grep)
    fi

    # build the filtering command
    for keyword in "$@"
    do
        local _COMMAND=$_COMMAND"$ACK $_OPTS --noenv --flush --passthru --color --color-match=\"${_COLORS[$_i]}\" '$keyword' |"
        _i=$_i+1
    done
    #trim ending pipe
    _COMMAND=${_COMMAND%?}
    #echo "$_COMMAND"
    cat - | eval $_COMMAND

}
