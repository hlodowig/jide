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
JIDE_CMD=
JIDE_CONFIGFILE=""
JIDE_ARGS=()

# Se lo script è un link di tipo '<progname>-<command>' 
# esegui: '<real progname> <command>' 
if [ -L "$JIDE_SCRIPT" ]; then 
	JIDE_SCRIPT=$(readlink -enqs $JIDE_SCRIPT)
	
	JIDE_CMD=$(basename "$(echo "$JIDE_PROGNAME-" | cut -s -d'-' -f2)" .sh)
	
	#echo "EXEC >>> $JIDE_SCRIPT $CMD"
	
	if [ -n "$JIDE_CMD=" ]; then 
		$JIDE_SCRIPT $JIDE_CMD $*
		exit $?
	fi
fi
	

JIDE_HOME=$(dirname $JIDE_SCRIPT)
JIDE_LIBDIR="lib"

import() 
{
	local LIB=$JIDE_HOME/$JIDE_LIBDIR/$(echo $1 | tr . /).sh
	if [ -f $LIB ]; then
		source $LIB
	else
		echo "JIDE import: $LIB not found!" 
		exit 1
	fi
}

##### IMPORT MODULES #####
import utils.common-utils
import utils.fs-utils
import utils.array-utils
import utils.java-utils

import jide.jide-common
import jide.jide-config
import jide.jide-init
import jide.jide-info
import jide.jide-compile
import jide.jide-run
import jide.jide-clean
import jide.jide-delete
import jide.jide-archive
##########################

jide_usage() 
{
	echo
	echo "$JIDE_PROGNAME <options> <command> <command_options>"
	echo
	echo "For more info print:"
	echo "$JIDE_PROGNAME [-h|--help] [command]"
	echo
}

jide_parse_main_options()
{
	ARG_ARRAY=$1
	
	eval set -- $(array_to_string $ARG_ARRAY)
	
	#echo "Argomenti prima di essere parsati: $*"
	
	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		eval set -- $( getopt -q -n "$JIDE_PROGNAME" -o hvp:D:C:xX \
			-l help,version,project:,project-discovery:,config:,gui,no-gui -- "$@"
		)

		#echo "Argomenti parsati: $*"
			
		while true ; do
			case "$1" in
				-p|--project) 
					if [ -z "$JIDE_PROJECT_HOME" ]; then
						JIDE_PROJECT_HOME="$2"
						echo "JIDE_PROJECT_HOME=$JIDE_PROJECT_HOME"
					else
						echo "Non posso settare la home directory del progetto"
						echo "Questa opzione va in conflitto con --project-discovery"
						return 1						
					fi
					__jide_remove_arg "$ARG_ARRAY" "$1" "$2"
					shift 2;;
				-D|--project-discovery) 
					if [ -z "$JIDE_PROJECT_HOME" ]; then
						eval JIDE_PROJECT_HOME=\"$(__jide_get_project_home_from_javafile "$2")\"
					else
						echo "Non posso attivare la procedura Project discovery"
						echo "Questa opzione va in conflitto con --project"
						return 1	
					fi
					__jide_remove_arg "$ARG_ARRAY" "$1" "$2"
					shift 2;;
				-C|--config) 
					JIDE_CONFIGFILE=$2; 
					__jide_remove_arg "$ARG_ARRAY" "$1" "$2"
					shift 2;;
				-x|--gui) 
					JIDE_GUI=1; 
					__jide_remove_arg "$ARG_ARRAY" "$1"
					shift ;;
				-X|--no-gui) 
					JIDE_GUI=0; 
					__jide_remove_arg "$ARG_ARRAY" "$1"
					shift ;;
				-h|--help) shift;;
				-v|--version) echo $JIDE_VERSION; exit 0;;
				--) shift;;
				init|compile|run|clean|delete|info|archive) 
					JIDE_CMD=$1
					__jide_remove_arg "$ARG_ARRAY" "$1"
					shift
					break ;;
				*) shift;;		
			esac
		done	
	fi
}

jide_main() 
{
	# Se al programma non vengono passati argomenti visualizza la stampa di 
	# utilizzo ed esci
	if [ ${#JIDE_ARGS[*]} -eq 0 ]; then
		jide_usage
		exit 1
	fi

	#echo "____________________________"
	#array_print JIDE_ARGS
	jide_parse_main_options JIDE_ARGS
	#echo
	#array_print JIDE_ARGS
	#echo "____________________________"
	
	if [ -z "$JIDE_CMD" ]; then
		print_error "No command"
		jide_usage
		exit 1
	else
		eval echo Eseguo il comando: jide_$JIDE_CMD $(array_to_string JIDE_ARGS)
		echo
		jide_config $JIDE_CONFIGFILE
		eval jide_$JIDE_CMD $(array_to_string JIDE_ARGS)
		exit $?
	fi
}

### END COMMANDS SECTION ###

### MAIN PROGRAM         ###

i=0
while [ -n "$1" ]
do
	JIDE_ARGS[$i]="$1"
	let i=$i+1
	shift
done

jide_main $*

