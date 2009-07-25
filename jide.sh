#!/bin/bash

###############################################################################
#                        JIDE: The Java IDE Script                            #
###############################################################################
# Author    : Luigi Capraro                                                   #
# E-mail    : luigi.capraro@gmail.com                                         #
# Copyright : GPL v.3                                                         #
#                                                                             #
# jide.sh                                                                     #
# This file is part of JIDE                                                   #
#                                                                             #
# Copyright (C) 2009 - Luigi Capraro                                          #
#                                                                             #
# JIDE is free software; you can redistribute it and/or modify                #
# it under the terms of the GNU General Public License as published by        #
# the Free Software Foundation; either version 2 of the License, or           #
# (at your option) any later version.                                         #
#                                                                             #
# JIDE is distributed in the hope that it will be useful,                     #
# but WITHOUT ANY WARRANTY; without even the implied warranty of              #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
# GNU General Public License for more details.                                #
#                                                                             #
# You should have received a copy of the GNU General Public License           #
# along with JIDE; if not, write to the Free Software                         #
# Foundation, Inc., 51 Franklin St, Fifth Floor,                              #
# Boston, MA  02110-1301  USA                                                 #
#                                                                             #
###############################################################################
 
### GLOBAL CONFIGURATION VAR ###

JIDE_SCRIPT=
JIDE_PROGNAME=
JIDE_CONFIGFILE="jide.config"
 
 
### COMMON FUNCTION      ###

### END COMMON FUNCTION  ###

# This function converts a relative path to an absolute path
get_absolute_path() {
   local FILEPATH=$(echo "$1" | awk '{gsub("^ *",""); print}')
   FILEPATH=$(echo "$FILEPATH" | awk '{gsub("^./",""); print}')
   
   if echo $FILEPATH | grep "^/" >/dev/null ; then
      # This is an absolute
      echo $FILEPATH
   else
      # This is a relative path
      echo "${PWD}/$FILEPATH"
   fi
}

print_error() {
	echo -e "JIDE ERROR: $*" >&2
}

### HELP SECTION         ###

jide_usage() {
	echo
	echo "$0 <options> <command> <command_options>"
	echo
	echo "For more info print:"
	echo "$0 [-?|-h|--help|help] [command]"
	echo
}

jide_help_config() {
	#TODO
	echo "HELP CONFIG"
}

jide_help_init() {
	#TODO
	echo "HELP INIT"
}

jide_help_compile() {
	#TODO
	echo "HELP COMPILE"
}

jide_help_run() {
	#TODO
	echo "HELP RUN"
}

jide_help_info() {
	#TODO
	echo "HELP INFO"
}

jide_help_clean() {
	#TODO
	echo "HELP CLEAN"
}


jide_help_delete() {
	#TODO
	echo "HELP DELETE"
}

jide_help_archive() {
	#TODO
	echo "HELP ARCHIVE"
}

jide_help() {
	if [ -z "$*" ]; then
		echo "Help"
	else
		jide_help_$1
	fi
}

### END HELP SECTION     ###

### COMMANDS SECTION     ###
jide_config() {

	#TODO
	echo "JIDE CONFIGURATION"
	
	JIDE_SCRIPT=$(get_absolute_path $JIDE_PROGNAME)
	JIDE_HOME=$(dirname $JIDE_SCRIPT)
	
	echo "JIDE_SCRIPT=$JIDE_SCRIPT"
	echo "JIDE_HOME=$JIDE_HOME"
	
	if [ -n "$1" ]; then	
		if [ -f "$1" ]; then
			echo "Configuration file: $1"	
			source $1
		else
			print_error "Configuration file: $1 not found"; exit 2;
		fi
	else
		for cfile in "$JIDE_CONFIGFILE" \
		              "config/$JIDE_CONFIGFILE" \
		              "/etc/jide/$JIDE_CONFIGFILE" \
		              "/usr/local/etc/jide/$JIDE_CONFIGFILE"
		do
			if [ -f "$cfile" ]; then
				echo "Configuration file: $cfile"	
				source $cfile	
				return 0
			fi
		done
	fi
	
	echo
	
	return 1;
}

jide_init() {
	#TODO
	echo "COMMAND='init'"
	echo "ARGS='$*'"
}

jide_compile() {
	#TODO
	echo "COMMAND='compile'"
	echo "ARGS=$*"
}

jide_run() {
	#TODO
	echo "COMMAND='run'"
	echo "ARGS=$*"
}

jide_info() {
	#TODO
	echo "COMMAND='info'"
	echo "ARGS=$*"
}

jide_clean() {
	#TODO
	echo "COMMAND='clean'"
	echo "ARGS=$*"
}


jide_delete() {
	#TODO
	echo "COMMAND='delete'"
	echo "ARGS=$*"
}

jide_archive() {
	#TODO
	echo "COMMAND='archive'"
	echo "ARGS=$*"
}


jide_main() {

	JIDE_PROGNAME=$0
	
	# Se lo script è un link di tipo '<progname>-<command>' 
	# esegui: '<real progname> <command>' 
	if [ -L "$JIDE_PROGNAME" ]; then 
		JIDE_SCRIPT=$(readlink -enqs $0)
		
		CMD=$(basename "$(echo "$JIDE_PROGNAME-" | cut -d'-' -f2)" .sh)
		
		#echo "EXEC >>> $JIDE_SCRIPT $CMD"
		
		if [ -n "$CMD" ]; then
			#echo "E' un link al comando $CMD"
			case $CMD in
				init|compile|run|clean|delete|info|archive) 
					exec $JIDE_SCRIPT $CMD $*;;
			esac
		fi
	fi
	
	# Se al programma non vengono passati argomenti visualizza la stampa di 
	# utilizzo ed esci
	if [ -z "$*" ]; then
		jide_usage
		exit 1
	fi
	
	# Analizza gli argomenti
	local CONFIGFILE=""
	local HELP=0;
	local CMD="";
	local ARGS="";
	
	while true; do
		case $1 in
			-?|-h|--help|help) HELP=1; shift;;
			-c|--config) CONFIGFILE=$2; shift 2;;
			init|compile|run|clean|delete|info|archive) CMD=$1; shift; ARGS=$*; break;;
			"") break;;
			*) echo print_error "Unknown Command: $1"; exit 1;;
		esac
	done
	
	# Se tra le optioni prima di un eventuale comando era presente l'optione di
	# help esegui tale comando
	if [ $HELP -eq 1 ]; then
		jide_help $CMD;
		exit 0
	fi
	
	if [ -z "$CMD" ]; then
		print_error "No command"
		jide_usage
		exit 1
	else
		jide_config $CONFIGFILE
		jide_$CMD $ARGS
		exit $?
	fi
}

### END COMMANDS SECTION ###

### MAIN PROGRAM         ###
jide_main $*


