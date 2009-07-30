#
# jide-info.sh
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
 
 
 

jide_help_info() 
{
cat << END
NAME
       $JIDE_PROGNAME - JIDE: Java IDE Project Management

SYNOPSIS
       $JIDE_PROGNAME info [OPTIONS]
       $JIDE_PROGNAME info [OPTIONS] -D [JAVA_FILE]

DESCRIPTION
       Get information from JIDE Project

OPTIONS
   Generic Program Information:
       -h, --help                             Print this message
       -V, --version                          Print version program

    Main options:
       -p, --project                          Set project root directory
       -D, --project-discovery  <java-file>   Set project root directory from a javafile of a JIDE Project
       -C, --config             <conf-file>   Set configuration file
       -x, --gui                              Abilità l'interfaccia grafica (deve essere installato zenity)
       -X, --no-gui                           Disabilita l'interfaccia grafica [DEFAULT]
    
    INIT options:
       -G, --get                <property>    Restituisce il valore della proprieta' del progetto indicata

    Project Properties:
       name                     Nome del progetto
       desc|description         Descrizione del progetto
       author                   Autore del progetto
       datatime                 Data e tempo di creazione del progetto
       root|home                Root directory del progetto
       scrdir                   Java source directory del progetto
       classdir                 Java class  directory del progetto

VERSION $JIDE_VERSION
AUTHOR  $JIDE_AUTHOR

EXAMPLES
	$JIDE_PROGNAME info [-p|--project] <project_dir>
	$JIDE_PROGNAME info [-p|--project] <project_dir> -x
	$JIDE_PROGNAME info [-p|--project] <project_dir> --get <property>

	$JIDE_PROGNAME info [-D|--project-discovery] <java_file>
	$JIDE_PROGNAME info [-D|--project-discovery] <java_file> -x
	$JIDE_PROGNAME info [-D|--project-discovery] <java_file> --get <property>

END
exit 0;
}

jide_info_print()
{
	echo "JIDE Project Info"
	echo
	printf "[*] %-20s %s\n" "Name"          "$(__jide_project_get_property JIDE_PROJECT_NAME)"
	printf "[*] %-20s %s\n" "Description"   "$(__jide_project_get_property JIDE_PROJECT_DESC)"
	printf "[*] %-20s %s\n" "Author"        "$(__jide_project_get_property JIDE_PROJECT_AUTHOR)"
	printf "[*] %-20s %s\n" "Creation time" "$(__jide_project_get_property JIDE_PROJECT_CTIME)"
	printf "[*] %-20s %s\n" "Project Path" "$JIDE_PROJECT_HOME"	
	printf "[*] %-20s %s\n" "Source  Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_SRCDIR"
	printf "[*] %-20s %s\n" "Classes Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CLASSDIR"
	echo
}

jide_info_gui()
{
	(
		printf "%s\n%s\n" "Name" "$(__jide_project_get_property JIDE_PROJECT_NAME)"
		printf "%s\n%s\n" "Description"   "$(__jide_project_get_property JIDE_PROJECT_DESC)"
		printf "%s\n%s\n" "Author"        "$(__jide_project_get_property JIDE_PROJECT_AUTHOR)"
		printf "%s\n%s\n" "Creation time" "$(__jide_project_get_property JIDE_PROJECT_CTIME)"
		printf "%s\n%s\n" "Project Path" "$JIDE_PROJECT_HOME"	
		printf "%s\n%s\n" "Source  Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_SRCDIR"
		printf "%s\n%s\n" "Classes Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CLASSDIR"
	) | zenity --width=600 --height=280 --title="JIDE Project Information" \
	           --list --column="Property" --column="Value" --print-column=2
}


jide_info() 
{
	#echo "COMMAND='info'"
	#echo "ARGS=$*"
	
	__jide_is_project_dir "$JIDE_PROJECT_HOME" || exit 1

	local INFO_GET=0
	local PROPERTY=""

	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -o D:p:hxX -l project:,project-discovery:,get:,help,gui,no-gui  -- "$@" 2> /dev/null)

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"
		
		while true ; do
			case "$1" in
				--get) INFO_GET=1; PROPERTY="$2"; shift 2 ;;
				-h|--help) jide_help_info; exit 0;;
				--) shift; break;;
				*) shift;;
			esac
		done	
	fi

	if [ $INFO_GET -eq 1 ] && [ -n "$PROPERTY" ]; then
		case "$PROPERTY" in
			name)             __jide_project_get_property JIDE_PROJECT_NAME;;
			desc|description) __jide_project_get_property JIDE_PROJECT_DESC;;
			author)           __jide_project_get_property JIDE_PROJECT_AUTHOR;;
			datatime)         __jide_project_get_property JIDE_PROJECT_CTIME;;
			srcdir)  get_absolute_path "$(__jide_project_get_property JIDE_PROJECT_SRCDIR)";;
			classdir)get_absolute_path "$(__jide_project_get_property JIDE_PROJECT_CLASSDIR)";;
			root|home)        echo "$JIDE_PROJECT_HOME"; return ;;
			*) echo "'$2': unknow property"; return 1;;
		esac
		return 0
	fi
	
	if __jide_is_gui_enabled; then
		#zenity --no-wrap --info --text="$(jide_info_print)"
		jide_info_gui
	else
		jide_info_print
	fi
	
	exit $?
}

