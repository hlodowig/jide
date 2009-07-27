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

__jide_get_prog() 
{
    ! test -e $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES/$1 && return 1

	case $1 in
		*[!0-9]*) echo $1;;
		*) readlink $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES/$1;;
	esac
}

__jide_run() 
{
	[ -z "$1" ] && return
	 
	local prog=$(__jide_get_prog "$1")
	
	if [ -n "$prog" ] || [ ${FORCE:=0} -eq 1 ]; then
		echo "JIDE Run program: $prog"
		echo
		$JAVA_VM -cp $JIDE_PROJECT_CLASSDIR:$CLASSPATH $prog || echo "Programma non valido"
	else
		print_error "Program not found!"		
	fi
}

__jide_get_main_classes_links() 
{
	ls -1 $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES | grep -e "^[0-9][0-9]*$"| sort -n
}

__jide_get_main_classes_number() 
{
	__jide_get_main_classes_links | wc -l | cut -d' ' -f1
}

__jide_print_main_classes() 
{
	local mp_links="$(__jide_get_main_classes_links)"
	local mp_num=$(__jide_get_main_classes_number)
	local mp_cifre=${#mp_num}
	echo "[*] Project Main class: $mp_num"
	for mp in $mp_links; do
		printf "    [%${mp_cifre}d] %s\n" $mp $(readlink $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES/$mp)
	done
}

jide_run() 
{
#	echo "COMMAND='run'"
#	echo "ARGS=$*"

	cd $JIDE_PROJECT_HOME
	
	if [ ! -d $JIDE_PROJECT_CONFIG_DIR ]; then
		echo "JIDE: Not project directory"
		exit -1
	fi

	if [ ! -d $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES ]; then
		echo "Project not compiled"
		exit -1
	else
		if [ -z "$(ls $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES)" ]; then
			echo "There are not main class in this project"
			exit -1		
		fi	
	fi

	if [ -z "$*" ]; then
		__jide_print_main_classes
		exit 0
	fi
	
	for prog in $*; do
		__jide_run $prog
	done
	
	exit $?
}


