#
# jide-init.sh
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
 
 
 
jide_help_init() 
{
	#TODO
	echo "HELP INIT"
}


jide_init() 
{
	echo "COMMAND='init'"
	echo "ARGS=$*"

	JIDE_PROJECT_HOME=${JIDE_PROJECT_HOME:=$PWD}
	echo "INIT: $(get_relative_path "$JIDE_PROJECT_HOME")"
		
	local FORCE=0
	local PROJ_NAME=$(basename $JIDE_PROJECT_HOME)
	local PROJ_AUTHOR=$USER
	
	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -q -o ?hs:c:n:d:a:f -l name:,description:,sourcepath:,classpath:,author:,help,force  -- "$@")

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"

		#echo $*
		
		while true ; do
			#echo $1
			case "$1" in
				-n|--name)        PROJ_NAME=$2             ; shift 2;;
				-d|--description) PROJ_DESC="$2"           ; shift 2;;
				-a|--author)      PROJ_AUTHOR="$2"         ; shift 2;;
				-s|--sourcepath)  JIDE_PROJECT_SRCDIR=$2   ; shift 2;;
				-c|--classpath)   JIDE_PROJECT_CLASSDIR=$2 ; shift 2;;
				-f|--force)       FORCE=1                  ; shift 1;;
				--) shift; break;;
				-h|-?|--help) jide_help_init; exit 0;;
				*) shift;;
			esac
		done	
	fi
	
	if [ ! -d "$JIDE_PROJECT_HOME" ]; then 
		if [ $FORCE -eq 1 ]; then
			echo "Create directory: '$JIDE_PROJECT_HOME'"
			mkdir $JIDE_PROJECT_HOME
		else
			echo "JIDE: Directory '$JIDE_PROJECT_HOME' not found!"
			return 2
		fi
	fi
	
	cd $JIDE_PROJECT_HOME
	
	if [ -d $JIDE_PROJECT_CONFIG_DIR ]; then
		if [ $FORCE -eq 0 ]; then
			echo "JIDE: You are in a project directory"
			exit -1
		fi
		
		rm $JIDE_PROJECT_CONFIG_DIR/*
	else
		mkdir $JIDE_PROJECT_CONFIG_DIR
	fi
	
	__jide_project_set_property JIDE_PROJECT_NAME   "$PROJ_NAME"
	__jide_project_set_property JIDE_PROJECT_DESC   "$PROJ_DESC"
	__jide_project_set_property JIDE_PROJECT_AUTHOR "$PROJ_AUTHOR"
	__jide_project_set_property JIDE_PROJECT_CTIME "$(date +'%Y-%m-%d %H:%M:%S')"
	
	__jide_set_project_home_dir   "$JIDE_PROJECT_HOME"
	__jide_set_project_source_dir "$JIDE_PROJECT_SRCDIR"
	__jide_set_project_class_dir  "$JIDE_PROJECT_CLASSDIR"
}

