#
# jide-compile.sh
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
 
 
 
jide_help_compile() 
{
	#TODO
	echo "HELP COMPILE"
	echo "$JIDE_PROGNAME compile [-s | --sourcepath <path>] [-c | --classpath <path>]"

}

jide_compile() 
{
	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -o hDs:c: -l sourcepath:,project-discovery,classpath:,help  -- "$@" 2> /dev/null)

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"
	
		local JFILES=${*%--}

		while true ; do
			case "$1" in
				-s|--sourcepath) JIDE_PROJECT_SRCDIR=$2;   shift 2;;
				-c|--classpath)  JIDE_PROJECT_CLASSDIR=$2; shift 2;;
				--) shift; break;;
				-h|--help) jide_help_compile; exit 0;;
				*) shift;;
			esac
		done	
	fi
	
	if __jide_is_gui_enabled; then
		( __jide_compile $JFILES ) | zenity --progress --pulsate --auto-close --text="Compilazione in corso..."
	else
		__jide_compile $JFILES
	fi

	
	exit $?
}

