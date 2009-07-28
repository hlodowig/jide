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
	cd $JIDE_PROJECT_HOME
	
	__jide_is_project_dir || exit 1

	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -o ?hs:c: -l sourcepath:,classpath:,help  -- "$@" 2> /dev/null)

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"


		while true ; do
			case "$1" in
				-s|--sourcepath) JIDE_PROJECT_SRCDIR=$2;   shift 2;;
				-c|--classpath)  JIDE_PROJECT_CLASSDIR=$2; shift 2;;
				--) shift; break;;
				-h|-?|--help) jide_help_compile; exit 0;;
				*) shift;;
			esac
		done	
	fi

	__jide_clean_project
		
	local compiled_class_num=0
	local mainclass_num=0
	local JFILES="$(__jide_get_source_files)"
	
	if [ -n "$JFILES" ]; then
		for jfile in $JFILES; do

			if java_compile "$jfile" "$JIDE_PROJECT_CLASSDIR"; then
				let compiled_class_num=$compiled_class_num+1
			fi
			
			echo $jfile >> $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES

			if __jide_mainclass_set "$jfile" $mainclass_num; then
				let mainclass_num=$mainclass_num+1
			fi
		done
	else 
		echo "No found java source files"
	fi

	printf "Compiled %d files\n"    $compiled_class_num
	printf "Main class found: %d\n" $mainclass_num

	exit $?
}

