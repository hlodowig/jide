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

JIDE_VERSION="0.1.3"
JIDE_AUTHOR="Luigi Capraro [luigi.capraro@gmail.com]"
JIDE_CONFIG_FILE="jide.config"
JIDE_GUI=0

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
JIDE_PROJECT_MAIN_CLASSDIR="main_classes"

################################  

### COMMON FUNCTION ### 

__jide_remove_arg() # Arg: <array_name>
{
	[ $# -lt 2 ] && return 1
	
	local ARRAY_S=$(array_to_string $1)	
	local OPT=$(echo "$2" | tr -d \')
	local ARG=$(echo "$3" | tr -d \')
	
	eval array_init $1 $(
		echo $ARRAY_S | sed "s/'$OPT' *'$ARG'//g" | \
			            sed "s/'$OPT *$ARG'//g"   | \
			            sed "s/'$OPT=$ARG'//g"    | \
			            sed "s/''//g"             | \
			            sed "s/^ *//g"
	)
}


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

__jide_project_get_name()
{
	__jide_project_get_property JIDE_PROJECT_NAME
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
		rm "$SRC_DIR/.jide-project" 2> /dev/null
		ln -fs "$PRJ_DIR" "$SRC_DIR/.jide-project"
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
	test -L "$(get_absolute_path "$1")/.jide-project"
}

__jide_get_project_home_from_javafile()
{
	test -z "$1"        && return 1 # No mainclass
	
	local ROOT_SRC="$(get_java_root_source_path "$1")"
	
	if __jide_is_project_source_dir "$ROOT_SRC"; then
		readlink $ROOT_SRC/.jide-project
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
	local PRJ_DIR=${JIDE_PROJECT_HOME:-${1:-$PWD}}
	
	if [ ! -d "$PRJ_DIR/$JIDE_PROJECT_CONFIG_DIR" ]; then
		echo "JIDE: The directory '$PRJ_DIR' isn't a JIDE Project"
		echo "      If you want make a project execute:"
		echo "      $JIDE_PROGNAME init <options>"
		return 1
	fi
		
	return 0
}

__jide_project_move_in()
{
	cd ${JIDE_PROJECT_HOME:-$PWD}
	__jide_is_project_dir
}

__jide_get_source_dir_list() 
{
	local SRCDIR="${JIDE_PROJECT_HOME:-$PWD}/$JIDE_PROJECT_SRCDIR"
	
	[ ! -d "$SRCDIR" ] && return 1
	ls -R  "$SRCDIR" | grep : | cut -d: -f1
}

__jide_get_source_dir_rlist() 
{
	local SRCDIR="${JIDE_PROJECT_HOME:-$PWD}/$JIDE_PROJECT_SRCDIR"
	
	[ ! -d "$SRCDIR" ] && return 1
	ls -R  "$SRCDIR" | grep : | cut -d: -f1 | sort -r
}

__jide_get_class_dir_list() 
{
	local CLASSDIR="${JIDE_PROJECT_HOME:-$PWD}/$JIDE_PROJECT_CLASSDIR"
	
	[ ! -d "$CLASSDIR" ] && return 1
	ls -R  "$CLASSDIR" | grep : | cut -d: -f1
}

__jide_get_class_dir_rlist() 
{
	local CLASSDIR="${JIDE_PROJECT_HOME:-$PWD}/$JIDE_PROJECT_CLASSDIR"
	
	[ ! -d "$CLASSDIR" ] && return 1
	ls -R  "$CLASSDIR" | grep : | cut -d: -f1 | sort -r
}

__jide_get_source_files() 
{
	local src_java_files
	for dir in $(__jide_get_source_dir_list); do
		src_java_files="$src_java_files $(ls $dir/*.java 2>/dev/null)"
	done
	
	echo $src_java_files
}

__jide_project_configure()
{
	#TODO
	echo "JIDE Configuration"
}

__jide_project_clean() 
{
	(
	  __jide_project_move_in 
	  cd $JIDE_PROJECT_CONFIG_DIR
	  rm -r $JIDE_PROJECT_JAVA_SOURCES 2> /dev/null
	  rm -r $JIDE_PROJECT_MAIN_CLASSDIR 2> /dev/null
	)
}

__jide_project_clean_sourcedir() 
{
	local SRCDIR_LIST="$(__jide_get_source_dir_rlist)"
	[ -z "$SRCDIR_LIST" ] && return 1
	
	for dir in $SRCDIR_LIST; do
		echo " * Clean  source directory: $dir"
		rm $dir/*~ 2> /dev/null
	done
}

__jide_project_clean_classdir() 
{
	local CLASSDIR_LIST="$(__jide_get_class_dir_rlist)"
	[ -z "$CLASSDIR_LIST" ] && return 1
	
	(
		__jide_project_move_in
		for dir in $CLASSDIR_LIST; do
			echo " * Clean  class  directory: $dir"
			rm $dir/*{~,.class} 2> /dev/null

			if [ "$dir" != "$JIDE_PROJECT_CLASSDIR" ] && [ -z "$(ls $dir)" ]
			then
				echo " * Remove class  directory: $dir"
				rm $dir 2> /dev/null
			fi
		done
	)
}


__jide_mainclass_get() 
{
	[ -z "$1" ] && return 1
	

	if is_java_mainclass "$1"; then
		get_java_classname "$1"
	else
		(
			__jide_project_move_in
			
			! is_directory "$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSDIR" && return 1
			
			cd "$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSDIR"

			! is_link "$1" && return 1

			case "$1" in
				*[!0-9]*) echo "$1";;
				*) readlink "$1";;
			esac
		)
	fi
}

__jide_mainclass_get_links() 
{
	(
		__jide_project_move_in
		cd $JIDE_PROJECT_CONFIG_DIR
		! is_directory $JIDE_PROJECT_MAIN_CLASSDIR && return 1
		ls -1 $JIDE_PROJECT_MAIN_CLASSDIR | grep -e "^[0-9][0-9]*$"| sort -n
	)
}

__jide_mainclass_number()
{
	__jide_mainclass_get_links | wc -l | cut -d' ' -f1
}

__jide_mainclass_print_list() 
{
	(
		__jide_project_move_in

		local mp_links="$(__jide_mainclass_get_links)"
		if [ -n "$mp_links" ]; then
			local mp_num=$(__jide_mainclass_number)
			local mp_cifre=${#mp_num}
			for mp in $mp_links; do
				printf "%d\t%s\n" $mp $(readlink $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSDIR/$mp)
			done
		fi
	)
}

__jide_mainclass_print_list2() 
{
	(
	__jide_project_move_in

	local mp_links="$(__jide_mainclass_get_links)"
	if [ -n "$mp_links" ]; then
		local mp_num=$(__jide_mainclass_number)
		local mp_cifre=${#mp_num}
		echo "[*] Project Main class: $mp_num"
		for mp in $mp_links; do
			printf "    [%${mp_cifre}d] %s\n" $mp $(readlink $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSDIR/$mp)
		done
	else
		echo "JIDE Project '$(__jide_project_get_name)': There aren't main class compiled!"
	fi
	)
}

__jide_mainclass_find_new_id()
{
	local mainclass_id=0
	
	mc_id_list="$(__jide_mainclass_get_links)"
	
	if [ -n "$mc_id_list" ]; then 
		for id in $mc_id_list; do
			if [ $mainclass_id -eq $id ]; then
				let mainclass_id=$mainclass_id+1
			fi
		done
	fi
	
	echo $mainclass_id
}

__jide_mainclass_set() 
{
	test -z "$1"        && return 1 # No mainclass
	#test -z "$2"        && return 2 # No mainclass id
	
	! is_java_file "$1" && return 3 # No java file (*.java)

	local jfile="$1"
	local mainclass_id
	local classname
	local mc_name
	
	if is_java_mainclass "$jfile"; then
	
		#echo "Trovato main in $jfile"
		classname=$(get_java_classname $jfile) 
		
		(
			#echo "Mainclass source file='$jfile'"		
			#echo "Mainclass classname='$classname'"
			
			__jide_project_move_in
			cd $JIDE_PROJECT_CONFIG_DIR
			
			if ! is_directory "$JIDE_PROJECT_MAIN_CLASSDIR"
			then
				#echo "Make dir: $(get_absolute path JIDE_PROJECT_MAIN_CLASSDIR)"
				mkdir "$JIDE_PROJECT_MAIN_CLASSDIR" || return 1
			fi
		
			cd "$JIDE_PROJECT_MAIN_CLASSDIR"
			
			if [ -n "$2" ]; then
				#echo "ID=$2 passato come parametro"

				mainclass_id=$2
			
				if [ -f $classname ]; then
					#echo "### Mainclass '$classname' esiste gia'"

					local mc_id=$(cat "$classname")
					if [ $mainclass_id -ne $mc_id ]; then					
						echo $mainclass_id > $classname
						#echo "Mainclass '$classname' rimuovi il vecchio link id=$mc_id"
						rm $mc_id
					else
						#echo "Mainclass '$classname' con stesso id=$2"
						#echo "Non fare nulla"

						return 0				
					fi
				else
					echo $mainclass_id > $classname				
				fi
				
				
				if [ -e "$mainclass_id" ]; then
					#echo "Mainclass ID=$2 esiste gia'"
			
					mc_name="$(__jide_mainclass_get $mainclass_id)"
				
					#echo "$mainclass_id --> $mc_name"
				
					if [ "$classname" != "$mc_name" ]; then

						#echo "Mainclass ID=$2 punta a una classe diversa da'$classname': '$mc_name'"
				
						#echo -n "'$mc_name' verra' spostata..."
					
						local mc_new_id=$(__jide_mainclass_find_new_id)
						#echo "il nuovo id e' $mc_new_id"
						
						echo $mc_new_id > $mc_name
						ln -sf $mc_name $mc_new_id
					#else
						#echo "Mainclass ID=$2 punta alla stessa classe '$classname'"
						#echo "non fare nulla!"
					fi
				fi

				#echo "Mainclass '$classname': crea link $mainclass_id"
				ln -sf $classname $mainclass_id

			else # mainclass id non specificato
				#echo "Mainclass ID non specificato"
				if [ ! -f "$classname" ]; then
					#echo -n "Trova il primo Mainclass ID disponibile..."
					mainclass_id=$(__jide_mainclass_find_new_id)
					#echo $mainclass_id
					echo $mainclass_id > $classname				

					#echo "Mainclass '$classname': crea link $mainclass_id"
					ln -sf $classname $mainclass_id
				else
					#echo "La main classe '$classname' gia' esiste"
					mainclass_id=$(cat "$classname")
				
					#echo "Main class ID=$mainclass_id"
				
					if [ -z "$mainclass_id" ]; then
						#echo "ma il contenuto è nullo"
						mainclass_id=$(__jide_mainclass_find_new_id)
						echo $mainclass_id > $classname
					fi
				
					if [ ! -e $mainclass_id ]; then
						#echo "ma non esiste il link provvedo a crealo (ID=$mainclass_id)"
						ln -sf $classname $mainclass_id
					else
						mc_name="$(__jide_mainclass_get $mainclass_id)"
				
						#echo "$mainclass_id --> $mc_name"
				
						if [ "$classname" != "$mc_name" ]; then

							#echo "Mainclass ID=$mainclass_id punta a una classe diversa da'$classname': '$mc_name'"
							#echo "'$classname' verra' spostata..."
					
							mainclass_id=$(__jide_mainclass_find_new_id)

							#echo "Mainclass '$classname': crea link $mainclass_id"
							#echo $mainclass_id > $classname
							ln -sf $classname $mainclass_id
						#else
							#echo "Mainclass ID=$mainclass_id punta alla stessa classe '$classname'"
							#echo "non fare nulla!"
						fi
					
					fi
				fi
			fi
		)
		return 0
	fi
	
	return 1
}

__jide_mainclass_run() 
{
	[ -z "$1" ] && return 1
	 
	local prog=$(__jide_mainclass_get "$1")
	
	if	__jide_is_project_javafile "$1" && is_java_mainclass "$1"; then
		JIDE_PROJECT_HOME="$(__jide_get_project_home_from_javafile "$1")"
	fi
	
	(		
		__jide_project_move_in
		
		if [ -n "$prog" ] || [ ${FORCE:=0} -eq 1 ]; then
			echo "JIDE Run program: $prog"
			echo
			$JAVA_VM -cp $JIDE_PROJECT_CLASSDIR:$CLASSPATH $prog || echo "Programma non valido"
		else
			echo "JIDE Project '$(__jide_project_get_name)': Program not found!"		
		fi
	)
}

__jide_compile() # args: java files
{	
	local JFILES="$*"
	if [ -n "$JFILES" ]; then
		for jfile in $JFILES; do
	
			if is_java_file "$jfile"; then
		
				jfile="$(get_absolute_path "$jfile")"
			
				local JIDE_PROJECT_HOME="$(__jide_get_project_home_from_javafile "$1")"	
				(
					__jide_project_move_in
					java_compile "$jfile" "$(__jide_get_project_class_dir)"	
					__jide_mainclass_set "$jfile"
				)
			fi	
		done
	else
		echo "Compila tutto il progetto"
		__jide_project_move_in
		__jide_project_clean

		local compiled_class_num=0
		local mainclass_num=0
		JFILES="$(__jide_get_source_files)"
	
		if [ -n "$JFILES" ]; then
			for jfile in $JFILES; do

				if java_compile "$jfile" "$JIDE_PROJECT_CLASSDIR"; then
					let compiled_class_num=$compiled_class_num+1
				fi

				if __jide_mainclass_set "$jfile" $mainclass_num; then
					let mainclass_num=$mainclass_num+1
				fi
			done
		else 
			echo "No found java source files"
		fi

		printf "Compiled %d files\n"    $compiled_class_num
		printf "Main class found: %d\n" $mainclass_num	
	fi
}

__jide_is_gui_enabled()
{
	test $JIDE_GUI -eq 1 && is_program_installed zenity
}




### END COMMON FUNCTION  ###
