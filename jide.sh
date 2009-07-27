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



JIDE_SCRIPT="$0"
JIDE_PROGNAME=$(basename "$JIDE_SCRIPT")

# Se lo script è un link di tipo '<progname>-<command>' 
# esegui: '<real progname> <command>' 
if [ -L "$JIDE_SCRIPT" ]; then 
	JIDE_SCRIPT=$(readlink -enqs $JIDE_SCRIPT)
	
	CMD=$(basename "$(echo "$JIDE_PROGNAME-" | cut -s -d'-' -f2)" .sh)
	
	#echo "EXEC >>> $JIDE_SCRIPT $CMD"
	
	if [ -n "$CMD" ]; then 
		$JIDE_SCRIPT $CMD "$*"
		exit $?
	fi
fi
	 
### GLOBAL CONFIGURATION VAR ###

# JIDE vars

JIDE_HOME=$(dirname $JIDE_SCRIPT)
JIDE_LIBDIR="lib"
JIDE_CONFIGFILE="jide.config"
JAVA_COMPILER="javac"

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
JIDE_PROJECT_MAIN_CLASSES="main_classes"
JIDE_PROJECT_JAVA_SOURCES="sources"
################################ 


### IMPORT MODELES         ###
import() 
{
	local LIB=$JIDE_HOME/$JIDE_LIBDIR/$1.sh
	[ -f $LIB ] && source $LIB || exit 1 
}

import fs
import java_utils
import jide-common
import jide-config
import jide-init
import jide-info
import jide-compile
import jide-run
import jide-clean
import jide-delete
import jide-archive
import jide-help

jide_usage() 
{
	echo
	echo "$JIDE_PROGNAME <options> <command> <command_options>"
	echo
	echo "For more info print:"
	echo "$JIDE_PROGNAME [-?|-h|--help|help] [command]"
	echo
}


jide_main() {

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

