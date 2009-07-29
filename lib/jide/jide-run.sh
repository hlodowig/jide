#
# jide-run.sh
# This file is part of JIDE
#
# Copyright (C) 2009 - Luigi Capraro
#
# JIDE is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# JIDE is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with JIDE; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, 
# Boston, MA  02110-1301  USA
 
 


jide_help_run() 
{
	#TODO
	echo "HELP RUN"
	echo "$JIDE_PROGNAME compile [-n|--name <project_name>] [-d|--description <project_description>] [-s | --sourcepath <path>] [-c | --classpath <path>] [-f|--force]"
}

jide_run() 
{
#	echo "COMMAND='run'"
#	echo "ARGS=$*"

	#cd $JIDE_PROJECT_HOME
	
	#__jide_is_project_dir || exit 1
	
	#if [ ! -d $JIDE_PROJECT_CONFIG_DIR ]; then
	#	echo "JIDE: Not project directory"
	#	exit -1
	#fi

	#if [ ! -d $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES ]; then
	#	echo "Project not compiled"
	#	exit -1
	#else
	#	if [ -z "$(ls $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES)" ]; then
	#		echo "There are not main class in this project"
	#		exit -1		
	#	fi	
	#fi
	
	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -o ?hDs:c: -l sourcepath:,project-discovery,classpath:,help  -- "$@" 2> /dev/null)

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"
	
		local ALL=0
		local JFILES=${*%--}

		while true ; do
			case "$1" in
				-s|--sourcepath) JIDE_PROJECT_SRCDIR=$2;   shift 2;;
				-c|--classpath)  JIDE_PROJECT_CLASSDIR=$2; shift 2;;
				-D|--project-discovery) ALL=1;shift;;
				--) shift; break;;
				-h|-?|--help) jide_help_compile; exit 0;;
				*) shift;;
			esac
		done	
	fi
	
	if [ -n "$1" ] && [ $ALL -eq 1 ]; then 
		local ROOT="$(__jide_get_project_home_from_javafile "$1")"
		if [ -n "$ROOT" ]; then
			JIDE_PROJECT_HOME="$ROOT"		
		fi
		
		JFILES=""
	fi

	if [ -z "$JFILES" ]; then
		if [ $JIDE_GUI -eq 1 ]; then
		__jide_mainclass_run  $(__jide_mainclass_print_list | tr '\t' '\n' | zenity --list --column="ID" --column="Program" --print-column=2 --text="Seleziona un programma" --title="JIDE Project '$(__jide_project_get_name)': Main classes" --width=300 --height=300)
		else
			__jide_mainclass_print_list2
		fi
		
		exit 0
	fi
	
	for prog in $JFILES; do
		__jide_mainclass_run $prog
	done
	
	exit $?
}


