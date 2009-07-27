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

function __find_program() {
	for mp in $(cat $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES); do
		if [ "$1" = "$mp" ]; then
			return 0
		fi
	done
	
	return 1
}

__get_prog() {

	local mp_num=$(wc -l $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES | cut -d' ' -f1)
	
	
	[ $1 -lt 0 ] || [ $1 -ge $mp_num ] && return
	
	local np=0
	for prog in $(cat $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES); do
		[ $1 -eq $((np++)) ] && __PROGNAME=$prog
	done
}

__run() {
	[ -z "$*" ] && return
	 
	local prog
	case $1 in
		*[!0-9]*) __find_program $1 && prog=$1;;
		*) __get_prog $1; prog=$__PROGNAME;;
	esac

	if [ -n "$prog" ]; then
		echo "Run program: $prog"
		java -cp $JIDE_PROJECT_CLASSDIR:$CLASSPATH $prog || echo "Programma non valido"
	else
		echo "Program not found!"		
	fi
}

__print_main_classes() {
	local mp_num=$(wc -l $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES | cut -d' ' -f1)
	local mp_cifre=${#mp_num}
	echo "[*] $mp_num Main class:"
	local x=0
	for mp in $(cat $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES); do
		printf "    [%${mp_cifre}d] %s\n" $((x++)) $mp
	done
}

jide_run() 
{
	echo "COMMAND='run'"
	echo "ARGS=$*"

	cd $JIDE_PROJECT_HOME
	
	if [ ! -d $JIDE_PROJECT_CONFIG_DIR ]; then
		echo "JIDE: Not project directory"
		exit -1
	fi

	if [ ! -f $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES ]; then
		echo "Project not compiled"
		exit -1
	else
		local mp_num=$(wc -l $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES | cut -d' ' -f1)
		
		if [ $mp_num -eq 0 ]; then
			echo "Thera are not main class in this project"
			exit -1		
		fi	
	fi

	if [ -z "$*" ]; then
		__print_main_classes
		exit 0
	fi
	
	for prog in $*; do
		__run $prog
	done
	
	exit $?
}


