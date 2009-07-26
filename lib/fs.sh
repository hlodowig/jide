
is_file() {
	test -f "$1"
}

is_directory() {
	test -d "$1"
}

is_valid_path() 
{
	test -e "$1"
}

clean_path() 
{
	[ -z "$1" ] && return 1
	local FILEPATH="$1"
	
#	echo "1. $FILEPATH"> /dev/stderr

	FILEPATH=$(echo "$FILEPATH" | awk '{gsub("^ *",""); print}')	
	FILEPATH=$(echo "$FILEPATH" | awk '{gsub(" *$",""); print}')	
#	echo "2. $FILEPATH"> /dev/stderr

	FILEPATH=$(echo "$FILEPATH" | awk '{gsub("[^\\.]\\.//*",""); print}')	
	FILEPATH=$(echo "$FILEPATH" | awk '{gsub("\\.$",""); print}')	
	FILEPATH=$(echo "$FILEPATH" | awk '{gsub("/$",""); print}')	
#	echo "3. $FILEPATH"> /dev/stderr

	FILEPATH=$(echo "$FILEPATH" | awk '{gsub("//*","/"); print}')	
#	echo "4. $FILEPATH" > /dev/stderr

	FILEPATH=$(echo "$FILEPATH" | awk '
		{ FILE=$0;
		  while(gsub("\\/[^/]*\\/\\.\\.", "", $FILE)>0) {} 
		  print $FILE
		}
	')
#	echo "5. $FILEPATH" > /dev/stderr
	
	echo $FILEPATH
}

get_filename() 
{
	[ -z "$1" ] && return 1
	clean_path $(basename "$1")
}

get_dirname()
{
	[ -z "$1" ] && return 1
	clean_path $(dirname "$1")	
}

is_absolute_path() 
{
	echo "$1" | grep -q -e "^ *\\/" && return 0 || return 1
}

is_relative_path()
{
	! is_absolute_path "$1"
}

# This function converts a relative path to an absolute path
get_absolute_path() 
{
	[ -z "$1" ] && return 1
	
	local FILEPATH
	FILEPATH="$(clean_path "$1")"
	if is_relative_path "$FILEPATH"; then
		#FILEPATH="${PWD}/$FILEPATH"
		FILEPATH="$(clean_path "${PWD}/$FILEPATH")"	
	fi
	
	echo "$FILEPATH"
}

# This function converts a relative path to an absolute path
get_relative_path() 
{
	[ -z "$1" ] && return 1
	
	local FILEPATH
	FILEPATH="$(clean_path "$1")"
	if is_absolute_path "$FILEPATH"; then
		FILEPATH="${FILEPATH#$PWD/}"	
	fi
	
	echo "$FILEPATH"
}

is_filename_with_extention()
{
	[ $# -lt 2 ] && return 1
	echo "$2" | grep -q ".$1$" 2> /dev/null
	return $?
}

get_file_access_time() {
	stat -c %X $1
}

get_file_modify_time() {
	stat -c %Y $1
}

get_file_change_time() {
	stat -c %Z $1
}

