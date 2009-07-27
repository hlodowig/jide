### COMMON FUNCTION      ###

# This function converts a relative path to an absolute path
get_absolute_path() {
   local FILEPATH=$(echo "$1" | awk '{gsub("^ *",""); print}')
   FILEPATH=$(echo "$FILEPATH" | awk '{gsub("^./",""); print}')
   
   if echo $FILEPATH | grep "^/" >/dev/null ; then
      # This is an absolute
      echo $FILEPATH
   else
      # This is a relative path
      echo "${PWD}/$FILEPATH"
   fi
}

get_var_value() {
	[ $# -lt 1 ] && return 1
	local VAR_VALUE
	eval  VAR_VALUE='$'"${1}"
	echo $VAR_VALUE
}

set_var_value() {
	[ $# -lt 2 ] && return 1
	local VARNAME=$1
	shift
	echo "$VARNAME=$*"
	eval $VARNAME=$*
}

print_error() {
	echo -e "$JIDE_PROGNAME: ERROR: $*" >&2
}

get_project_property() {

	[ -z "$1" ] && return 1

	cd $JIDE_PROJECT_HOME
	
	case $1 in
		JIDE_PROJECT_SRCDIR|JIDE_PROJECT_CLASSDIR) 
			get_var_value $1;;
		JIDE_PROJECT_NAME|JIDE_PROJECT_DESC|JIDE_PROJECT_CTIME|JIDE_PROJECT_AUTHOR)
			local FILE=$JIDE_PROJECT_CONFIG_DIR/$(get_var_value $1)
			[ -f $FILE ] && cat $FILE;;
		*) return 1;;
	esac
	return 0
}

set_project_property() {
	cd $JIDE_PROJECT_HOME

	case $1 in
		JIDE_PROJECT_SRCDIR|JIDE_PROJECT_CLASSDIR) 
			set_var_value $1 $2;;
		JIDE_PROJECT_NAME|JIDE_PROJECT_DESC|JIDE_PROJECT_CTIME|JIDE_PROJECT_AUTHOR) 
			echo $2 > $JIDE_PROJECT_CONFIG_DIR/$(get_var_value $1);;
		*) return 1;;
	esac
	return 0
}

get_classname() {
	test $# -eq 0 && return
	
	local CLASSNAME=$1
	
	if [ $# -gt 1 ]; then
		CLASSNAME=${1#$2}
	fi
	
	CLASSNAME=${CLASSNAME#/}
	CLASSNAME=${CLASSNAME%.*}
	CLASSNAME=${CLASSNAME//\//.}
	
	echo $CLASSNAME
}

get_classfile() {
	test $# -eq 0 && return
	
	if [ $# -eq 1 ] || [ $# -eq 3 ]; then
	
		local CLASSNAME=${1//.java/.class}
	
		if [ "$2" != "$3" ]; then
			CLASSNAME=${CLASSNAME#$2}
			CLASSNAME=${CLASSNAME#/}
			CLASSNAME=$3/$CLASSNAME
		fi

		echo $CLASSNAME
		return 0	
	fi

	return 1
}

get_file_mod_time() {
	stat -c %Y $1
}

function find_program() {
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
		*[!0-9]*) find_program $1 && prog=$1;;
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

### END COMMON FUNCTION  ###

