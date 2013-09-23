#!/bin/bash

# INSTALL:
#   * put something like this in your .bashrc:
#     . /path/to/h.sh
#   * or just copy and paste the function in your .bashrc

#### colorize helper script that uses ack (ack-grep)
h() {
	local _i=0
	#inverted colors last scheme
	local _COLORS=( "underline bold red" "underline bold green" "underline bold yellow"  "underline bold blue"  "underline bold magenta" "bold on_red" "bold on_green" "bold black on_yellow" "bold on_blue" "bold on_magenta" "bold on_cyan" "bold black on_white"	)
	#inverted colors first scheme
	#_COLORS=( "bold on_red" "bold on_green" "bold black on_yellow" "bold on_blue" "bold on_magenta" "bold on_cyan" "bold black on_white"  "underline bold red" "underline bold green" "underline bold yellow"  "underline bold blue"  "underline bold magenta" 	)

	for keyword in "$@"
	do
		local _COMMAND=$_COMMAND"ack --flush --passthru --color --color-match=\"${_COLORS[$_i]}\" $keyword |"
	    _i=$_i+1
	done
	#trim ending pipe
	_COMMAND=${_COMMAND%?}
	#echo "$_COMMAND"
	cat | eval $_COMMAND
}



