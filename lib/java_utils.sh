#source fs.sh

is_java_filename() # arg: filename 
{
	is_filename_with_extention "[Jj][Aa][Vv][Aa]" "$1"
}

is_java_file() # arg: file 
{
	is_file "$1" && is_java_filename "$1"
}


get_java_package() # arg: javafile
{
	test -z "$1"      && return 1 # No input
	! is_java_file $1 && return 2 # No java file (*.java)
	
	local PACKAGE
	PACKAGE=$(cat $1 | grep "package.*;")
	[ -z "$PACKAGE" ] && return 1
	PACKAGE=$(echo $PACKAGE | cut -d';' -f1)
	PACKAGE=${PACKAGE#"package"}
	
	echo $PACKAGE
}

get_java_root_source_path() # arg: javafile
{
	test -z "$1"      && return 1 # No input
	! is_java_file "$1" && return 2 # No java file (*.java)

	local PACKAGE
	
	PACKAGE=$(get_java_package "$1" | tr . /)
	
	local SRC="$PWD"
	
	if [ -n "$PACKAGE" ]; then 
		SRC="$PWD/$(get_dirname "$1")"
		SRC="$(clean_path "$SRC")"
		if echo "$SRC" | grep -q -e "$PACKAGE$"; then
			SRC="${SRC%$PACKAGE}"
			SRC="$(clean_path "$SRC")"
		else
			return 1
		fi
	fi
	
	echo "$SRC"
}

is_java_valid_filepath() # arg: javafile
{
	get_java_root_source_path "$1" > /dev/null
}

is_java_valid_filename() # arg: javafile
{
	test -z "$1"        && return 1 # No input
	! is_java_file "$1" && return 2 # No java file (*.java)

	local CLASSNAME=$(get_filename "$1" | cut -d. -f1)
	
	cat "$1" | grep -q -e "class *$CLASSNAME"
}

is_java_valid_file() # arg: javafile
{
	is_java_valid_filename "$1" && is_java_valid_filepath "$1"
}


get_java_classname() # arg: javafile
{
	test -z "$1"        && return 1 # No input
	! is_java_file "$1" && return 2 # No java file (*.java)

	echo "$(get_java_package "$1").$(get_filename "$1" | cut -d. -f1)"
}

get_java_classfile() # arg: javafile [classdir]
{
	test -z "$1"      && return 1 # No input
	! is_java_file "$1" && return 2 # No java file (*.java)

	local JFILE
	
	JFILE="$(get_java_classname "$1" | tr . /).class"
	
	if [ -z "$2" ]; then
		echo "$(get_java_root_source_path "$1")/$JFILE"	
	elif [ -d "$2" ]; then
		echo "$(get_absolute_path "$2")/$JFILE"
	else
		return 1
	fi
	
	return 0
}

is_java_mainclass() # arg: javafile
{
	test -z "$1"      && return 1 # No input
	! is_java_file "$1" && return 2 # No java file (*.java)
	
	cat "$1" | grep -q -e "static.*void *main *(.*)"
}

