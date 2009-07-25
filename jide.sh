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

# JIDE vars
JIDE_SCRIPT=
JIDE_PROGNAME=
JIDE_HOME=
JIDE_CONFIGFILE="jide.config"

#JIDE Project vars
JIDE_PROJECT_HOME=
JIDE_PROJECT_CONFIG_DIR=".jide"
JIDE_PROJECT_CONFIG_FILE="jide.config"
JIDE_PROJECT_SRCDIR="src"
JIDE_PROJECT_CLASSDIR="classes"
JIDE_PROJECT_NAME="name"
JIDE_PROJECT_DESC="desc"
JIDE_PROJECT_CTIME="ctime"
JIDE_PROJECT_AUTHOR="author"

################################ 
 
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

get_var_value() {
	[ $# -lt 1 ] && return 1
	local VAR_VALUE
	eval  VAR_VALUE='$'"${1}"
	echo $VAR_VALUE
}

set_var_value() {
	[ $# -lt 2 ] && return 1
	local VARNAME=$1
	shift
	echo "$VARNAME=$*"
	eval $VARNAME=$*
}

print_error() {
	echo -e "$JIDE_PROGNAME: ERROR: $*" >&2
}

get_project_property() {

	[ -z "$1" ] && return 1

	cd $JIDE_PROJECT_HOME
	
	case $1 in
		JIDE_PROJECT_SRCDIR|JIDE_PROJECT_CLASSDIR) 
			get_var_value $1;;
		JIDE_PROJECT_NAME|JIDE_PROJECT_DESC|JIDE_PROJECT_CTIME|JIDE_PROJECT_AUTHOR)
			local FILE=$JIDE_PROJECT_CONFIG_DIR/$(get_var_value $1)
			[ -f $FILE ] && cat $FILE;;
		*) return 1;;
	esac
	return 0
}

set_project_property() {
	cd $JIDE_PROJECT_HOME

	case $1 in
		JIDE_PROJECT_SRCDIR|JIDE_PROJECT_CLASSDIR) 
			set_var_value $1 $2;;
		JIDE_PROJECT_NAME|JIDE_PROJECT_DESC|JIDE_PROJECT_CTIME|JIDE_PROJECT_AUTHOR) 
			echo $2 > $JIDE_PROJECT_CONFIG_DIR/$(get_var_value $1);;
		*) return 1;;
	esac
	return 0
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
		             "$JIDE_HOME/config/$JIDE_CONFIGFILE" \
		             "/etc/jide/$JIDE_CONFIGFILE" \
		             "/usr/local/etc/jide/$JIDE_CONFIGFILE"
		do
			if [ -f "$cfile" ]; then
				echo "Configuration file: $cfile"	
				source $cfile	
			fi
		done
	fi
	
	echo
	cd $JIDE_PROJECT_HOME

	if [ -f "$JIDE_PROJECT_CONFIG_FILE" ]; then
		echo "Configuration file: $JIDE_PROJECT_CONFIG_FILE"	
		source $JIDE_PROJECT_CONFIG_FILE
	fi
	
	return 0;
}

jide_init() {
	echo "COMMAND='init'"
	echo "ARGS=$*"
	
	cd $JIDE_PROJECT_HOME
	
	local FORCE=0
	local PROJ_NAME=$(basename $JIDE_PROJECT_HOME)
	local PROJ_AUTHOR=$USER
	
	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -o ?hs:c:n:d:a:f -l name:,description:,sourcepath:,classpath:,author:,help  -- "$@")

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"

		#echo $*
		
		while true ; do
			#echo $1
			case "$1" in
				-n|--name) PROJ_NAME=$2; shift 2;;
				-d|--description) PROJ_DESC="$2"; shift 2;;
				-a|--author) PROJ_AUTHOR="$2"; shift 2;;
				-s|--sourcepath) 
					$JIDE_PROJECT_SRCDIR=$2
					echo "JIDE_PROJECT_SRCDIR=$JIDE_PROJECT_SRCDIR" >> $JIDE_PROJECT_CONFIG_FILE   
					shift 2;;
				-c|--classpath)  
					$JIDE_PROJECT_CLASSDIR=$2 
					echo "JIDE_PROJECT_CLASSDIR=$JIDE_PROJECT_CLASSDIR" >> $JIDE_PROJECT_CONFIG_FILE   					
					shift 2;;
				-f|--force) FORCE=1; shift;;
				--) shift; break;;
				-h|-?|--help) jide_help_init; exit 0;;
				*) shift;;
			esac
		done	
	fi
	
	if [ -d $JIDE_PROJECT_CONFIG_DIR ]; then
		if [ $FORCE -eq 0 ]; then
			echo "JIDE: You are in a project directory"
			exit -1
		fi
		
		rm $JIDE_PROJECT_CONFIG_DIR/*
	else
		mkdir $JIDE_PROJECT_CONFIG_DIR
	fi
	
	set_project_property JIDE_PROJECT_NAME   "$PROJ_NAME"
	set_project_property JIDE_PROJECT_DESC   "$PROJ_DESC"
	set_project_property JIDE_PROJECT_AUTHOR "$PROJ_AUTHOR"
	set_project_property JIDE_PROJECT_CTIME "$(date +'%Y-%m-%d %H:%M:%S')"
	
	mkdir -p $JIDE_PROJECT_SRCDIR
	mkdir -p $JIDE_PROJECT_CLASSDIR
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
	
	cd $JIDE_PROJECT_HOME
	
	if [ ! -d $JIDE_PROJECT_CONFIG_DIR ]; then
		echo "JIDE: Not project directory"
		exit -1
	fi
	
	echo "JIDE Project Info"
	echo
	printf "[*] %-20s %s\n" "Name"          "$(get_project_property JIDE_PROJECT_NAME)"
	printf "[*] %-20s %s\n" "Description"   "$(get_project_property JIDE_PROJECT_DESC)"
	printf "[*] %-20s %s\n" "Author"        "$(get_project_property JIDE_PROJECT_AUTHOR)"
	printf "[*] %-20s %s\n" "Creation time" "$(get_project_property JIDE_PROJECT_CTIME)"
	printf "[*] %-20s %s\n" "Project Path" "$JIDE_PROJECT_HOME"	
	printf "[*] %-20s %s\n" "Source  Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_SRCDIR"
	printf "[*] %-20s %s\n" "Classes Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CLASSDIR"
	echo
	
	exit $?
}

jide_clean() {
	#TODO
	echo "COMMAND='clean'"
	echo "ARGS=$*"
}


jide_delete() {
	echo "COMMAND='delete'"
	echo "ARGS=$*"
	
	cd $JIDE_PROJECT_HOME
	
	rm -r $JIDE_PROJECT_CONFIG_DIR
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

	JIDE_PROJECT_HOME=$PWD
		
	while true; do
		case $1 in
			-?|-h|--help|help) HELP=1; shift;;
			-c|--config) CONFIGFILE=$2; shift 2;;
			-p|--project) JIDE_PROJECT_HOME=$2; shift 2;;
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


