#!/bin/bash

# INSTALL:
#   * put something like this in your .bashrc:
#     . /path/to/h.sh
#   * or just copy and paste the function in your .bashrc

#### colorize helper script that uses ack (ack-grep)
h() {

	_usage() { 
		echo "usage: YOUR_COMMAND | h [-i] [-Q] args...
	-i : case insensitive
	-Q : disable regexp"
	}

	local _OPTS

	# detect pipe or direct
	if test -t 0; then 
		_usage
		return
	fi

	# magae flags
	while getopts ":iQ" opt; do
	    case $opt in 
	       i) _OPTS+=" -i " ;;
	       Q)  _OPTS+=" -Q " ;;
	           # $OPTARG is the option's argument ;;
	       \?) _usage
				return ;;
	    esac
	done
	
	shift $(($OPTIND - 1))

	# check maximum allowed input
	if (( ${#@} > 12)); then
		echo "Too many terms. h supports a maximum of 12 groups. Consider relying on regular expression supported patterns like \"word1\\|word2\""
		exit -1
	fi;

	# set zsh compatibility
	[[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays && setopt ignorebraces

	local _i=0

	#inverted-colors-last scheme
	_COLORS=( "underline bold red" "underline bold green" "underline bold yellow"  "underline bold blue"  "underline bold magenta"  "underline bold cyan" "bold on_red" "bold on_green" "bold black on_yellow" "bold on_blue"  "bold on_cyan" "bold on_magenta"  )
	#inverted-colors-first scheme
	#_COLORS=( "bold on_red" "bold on_green" "bold black on_yellow" "bold on_blue" "bold on_magenta" "bold on_cyan" "bold black on_white"  "underline bold red" "underline bold green" "underline bold yellow"  "underline bold blue"  "underline bold magenta" 	)

	# build the filtering command
	for keyword in "$@"
	do
		local _COMMAND=$_COMMAND"ack $_OPTS --flush --passthru --color --color-match=\"${_COLORS[$_i]}\" $keyword |"
	    _i=$_i+1
	done
	#trim ending pipe
	_COMMAND=${_COMMAND%?}
	#echo "$_COMMAND"
	cat - | eval $_COMMAND
}



