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
	#TODO
	echo "COMMAND='compile'"
	echo "ARGS=$*"
	
	cd $JIDE_PROJECT_HOME

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
	
	if [ ! -d $JIDE_PROJECT_CLASSDIR ]; then
		echo "Create classes dir: $JIDE_PROJECT_CLASSDIR"
		mkdir $JIDE_PROJECT_CLASSDIR
	fi

	rm -r $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES 2> /dev/null
	touch $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES
	rm -r $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES 2> /dev/null
	touch $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVE_SOURCES

	rm -r $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES.d 2> /dev/null
	mkdir $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES.d
	
	local JDIRS="$(ls -R $JIDE_PROJECT_SRCDIR | grep : | cut -d: -f1)"
	local JFILES=""
	
	echo $JDIRS
	
	for dir in $JDIRS; do
		JFILES="$JFILES $(ls $dir/*.java 2>/dev/null)"
	done

	#echo -e $JFILES
	
	local cf=0
	local mf=0
	local classname
	
	if [ -n "$JFILES" ]; then
		for jfile in $JFILES; do
			echo $jfile >> $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES
			
			cfile=$(get_java_classfile $jfile $JIDE_PROJECT_CLASSDIR)
			if is_java_mainclass "$jfile"; then
				#echo "Trovato main in $jfile"
				classname=$(get_java_classname $jfile) 
				echo $classname >> $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES
				(
					cd $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES.d
					echo $mf > $classname
					ln -sf $classname $mf
				)
				let mf=$mf+1
			fi
			
			if [ ! -f "$cfile" ] || [ $(get_file_modify_time $jfile) -gt $(get_file_modify_time $cfile) ]; then
				echo "Compile: $jfile --> $cfile"
				$JAVA_COMPILER -sourcepath $JIDE_PROJECT_SRCDIR -d $JIDE_PROJECT_CLASSDIR $jfile
				let cf=$cf+1
			fi
		done
	else 
		echo "No found java source files"
	fi

	printf "Compiled %d files\n" $cf

	exit $?
}

