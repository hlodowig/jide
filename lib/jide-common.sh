#
# jide-common.sh
# This file is part of JIDE
#
# Copyright (C) 2009 - Wataru
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


### GLOBAL CONFIGURATION VAR ###

# JIDE vars

JIDE_CONFIG_FILE="jide.config"
JAVA_COMPILER="javac"
JAVA_VM="java"

#JIDE Project vars
JIDE_PROJECT_HOME=
JIDE_PROJECT_CONFIG_DIR=".jide"
JIDE_PROJECT_CONFIG_FILE="jide.config"

JIDE_PROJECT_SRCDIR="src"
JIDE_PROJECT_CLASSDIR="classes"
JIDE_PROJECT_NAME="name"
JIDE_PROJECT_DESC="desc"
JIDE_PROJECT_CTIME="ctime"
JIDE_PROJECT_AUTHOR="author"
JIDE_PROJECT_MAIN_CLASSES="main_classes"
JIDE_PROJECT_JAVA_SOURCES="sources"
################################  

### COMMON FUNCTION ### 
 
__jide_project_get_property() 
{

	[ -z "$1" ] && return 1

	cd $JIDE_PROJECT_HOME
	
	case $1 in
		JIDE_PROJECT_SRCDIR|JIDE_PROJECT_CLASSDIR) 
			get_var $1;;
		JIDE_PROJECT_NAME|JIDE_PROJECT_DESC|JIDE_PROJECT_CTIME|JIDE_PROJECT_AUTHOR)
			local FILE=$JIDE_PROJECT_CONFIG_DIR/$(get_var $1)
			[ -f $FILE ] && cat $FILE;;
		*) return 1;;
	esac
	return 0
}

__jide_project_set_property() 
{
	cd $JIDE_PROJECT_HOME

	case $1 in
		JIDE_PROJECT_SRCDIR|JIDE_PROJECT_CLASSDIR) 
			set_var $1 $2;;
		JIDE_PROJECT_NAME|JIDE_PROJECT_DESC|JIDE_PROJECT_CTIME|JIDE_PROJECT_AUTHOR) 
			echo $2 > $JIDE_PROJECT_CONFIG_DIR/$(get_var $1);;
		*) return 1;;
	esac
	return 0
}

__jide_set_project_home_dir()
{
	local PRJ_DIR
	if [ -n "$1" ]; then	
		PRJ_DIR="$1"
	else
		PRJ_DIR=${JIDE_PROJECT_HOME:-"."}
	fi
	
	[ ! -d "$PRJ_DIR" ] && return 1

	cd "$PRJ_DIR"

	if __jide_is_project_dir "$PRJ_DIR"; then
		JIDE_PROJECT_HOME="$(get_absolute_path "$PRJ_DIR")"
		ln -fs "$JIDE_PROJECT_HOME" "$JIDE_PROJECT_CONFIG_DIR/root_dir"
	fi
}

__jide_set_project_source_dir()
{
	cd $JIDE_PROJECT_HOME
	
	if __jide_is_project_dir; then
		local PRJ_DIR="$(get_absolute_path "$JIDE_PROJECT_HOME")"
		local SRC_DIR="$(get_absolute_path "$1")"
		
		[ ! -d "$SRC_DIR" ] && mkdir "$SRC_DIR"
		ln -fs "$SRC_DIR" "$JIDE_PROJECT_CONFIG_DIR/src_dir"
		rm "$SRC_DIR/.jide-src" 2> /dev/null
		ln -fs "$PRJ_DIR" "$SRC_DIR/.jide-src"
	fi	
}

__jide_set_project_class_dir()
{
	cd ${JIDE_PROJECT_HOME:=.}
	
	if __jide_is_project_dir; then
		local PRJ_DIR="$(get_absolute_path "$JIDE_PROJECT_HOME")"
		local CLASS_DIR="$(get_absolute_path "$1")"

		[ ! -d "$CLASS_DIR" ] && mkdir "$CLASS_DIR"		
		ln -fs "$CLASS_DIR" "$JIDE_PROJECT_CONFIG_DIR/class_dir"
	fi	
}

__jide_get_project_source_dir() # No args
{
	cd ${JIDE_PROJECT_HOME:=.}
	
	if __jide_is_project_dir; then
		readlink $JIDE_PROJECT_CONFIG_DIR/src_dir
	else
		return 1
	fi	
}

__jide_get_project_class_dir() # No args
{
	cd ${JIDE_PROJECT_HOME:=.}
	
	if __jide_is_project_dir; then
		readlink $JIDE_PROJECT_CONFIG_DIR/class_dir
	else
		return 1
	fi	
}

__jide_is_project_source_dir()
{
	test -L "$(get_absolute_path "$1")/.jide-src"
}

__jide_get_project_home_from_javafile()
{
	test -z "$1"        && return 1 # No mainclass
	
	local ROOT_SRC="$(get_java_root_source_path "$1")"
	
	if __jide_is_project_source_dir "$ROOT_SRC"; then
		readlink $ROOT_SRC/.jide-src
		return 0
	fi
	
	return 1
}

__jide_is_project_javafile()
{
	__jide_is_project_source_dir "$(get_java_root_source_path "$1")"
}

__jide_is_project_dir()
{
	local PRJ_DIR
	if [ -n "$1" ]; then
		PRJ_DIR="$1"
	else
		PRJ_DIR=${JIDE_PROJECT_HOME:-"."}
	fi
	
	if [ ! -d $PRJ_DIR/$JIDE_PROJECT_CONFIG_DIR ]; then
		echo "JIDE: This directory isn't a JIDE Project"
		echo "      If you want make a project execute:"
		echo "      $JIDE_PROGNAME init <option>"
		return 1
	fi
	
	return 0
}

__jide_get_source_dir_list() 
{
	ls -R "$JIDE_PROJECT_HOME/$JIDE_PROJECT_SRCDIR" | grep : | cut -d: -f1
}

__jide_get_class_dir_list() 
{
	ls -R "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CLASSDIR" | grep : | cut -d: -f1
}

__jide_get_source_files() 
{
	local src_java_files
	for dir in $(__jide_get_source_dir_list); do
		src_java_files="$src_java_files $(ls $dir/*.java 2>/dev/null)"
	done
	
	echo $src_java_files
}

__jide_get_prog() 
{
    ! test -e $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES/$1 && return 1

	case $1 in
		*[!0-9]*) echo $1;;
		*) readlink $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES/$1;;
	esac
}

__jide_project_configure()
{
	#TODO
	echo "JIDE Configuration"
}

__jide_project_clean() 
{
	( 
	  cd $JIDE_PROJECT_HOME/$JIDE_PROJECT_CONFIG_DIR
	  rm -r $JIDE_PROJECT_JAVA_SOURCES 2> /dev/null
	  rm -r $JIDE_PROJECT_MAIN_CLASSES 2> /dev/null
	)
}

__jide_project_clean_sourcedir() 
{
	for dir in $(__jide_get_source_dir_list); do
		rm $dir/*~ 2> /dev/null
	done
}

__jide_project_clean_classdir() 
{
	for dir in $(__jide_get_class_dir_list); do
		rm $dir/*{~,.class} 2> /dev/null
	done
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

__jide_process_mainclass() 
{
	test -z "$1"        && return 1 # No mainclass
	test -z "$2"        && return 2 # No mainclass id
	
	! is_java_file "$1" && return 3 # No java file (*.java)

	local jfile="$1"
	local mainclass_id=$2
	local classname
	
	if is_java_mainclass "$jfile"; then
	
		! is_directory "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES" &&
		mkdir "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES"

		#echo "Trovato main in $jfile"
		classname=$(get_java_classname $jfile) 
		(
			cd "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES"
			echo $mainclass_id > $classname
			ln -sf $classname $mainclass_id
		)
		return 0
	fi
	
	return 1
}

__jide_get_main_classes_links() 
{
	ls -1 $JIDE_PROJECT_HOME/$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES | grep -e "^[0-9][0-9]*$"| sort -n
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

__jide_compile_javafile() #
{
	test -z "$1"        && return 1 # No mainclass
	test -z "$2"        && return 2 # No mainclass id
	
	local PRJ_DIR="$(__jide_get_project_home_from_javafile "$1")"
	
	test -z "$PRJ_DIR" && return 3 # No javafile of JIDE project
	
	JIDE_PROJECT_HOME="$PRJ_DIR"
	
	local SRCDIR="$(__jide_get_project_source_dir)"
	local CLASSDIR="$(__jide_get_project_class_dir)"
	
	if java_compile "$1" "$CLASSDIR"; then
	
		if ! is_file $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES; then
			echo $jfile > $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES
		else
			if ! cat $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES | grep -q "$jfile"; then
				echo $jfile >> $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES			
			fi
		fi
	
		__jide_process_mainclass "$jfile"
	fi	
}


### END COMMON FUNCTION  ###

