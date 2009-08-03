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
	
	local ALL=0
	local LIST=0
	local JFILES=
	
	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -o hla -l help,list,all  -- "$@")

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"
		
		while true ; do
			case "$1" in
				-a|--all)  ALL=1; shift;;
				-l|--list) LIST=1; shift;;
				--) shift; break;;
				-h|--help) jide_help_run; exit 0;;
				*) shift;;
			esac
		done
		
		JFILES=$*
	fi

	__jide_is_project_dir $JIDE_PROJECT_HOME || exit 1

	
	if [ $ALL -eq 1 ]; then
	
		JFILES=$(__jide_mainclass_get_links)
	
	elif [ -z "$JFILES" ]; then

		if [ $LIST -eq 0 ] && [ $(__jide_mainclass_number) -eq 1 ]; then
			__jide_mainclass_run 0
		else
			if [ $JIDE_GUI -eq 1 ]; then
				__jide_mainclass_run  $(__jide_mainclass_print_list | tr '\t' '\n' | zenity --list --column="ID" --column="Program" --print-column=2 --text="Seleziona un programma" --title="JIDE Project '$(__jide_project_get_name)': Main classes" --width=300 --height=300)
			else
				__jide_mainclass_print_list | awk '{printf "[%d] %s\n", $1, $2}'
			fi
		fi
		exit 0
	fi
	
	for prog in $JFILES; do
		__jide_mainclass_run $prog
	done
	
	exit $?
}


