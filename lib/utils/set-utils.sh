
# Init set with value 
set_init() # Args: <set_name> <arg1> ...
{
	[ -z "$1" ] && return 1
	
	local SET_NAME=$1
	eval "$SET_NAME=()"

	set_insert $*	
}

# Clean set
set_clean() # Args: <set_name>
{
	list_clean $1
}

# Return size of set
set_size() # Args: <set_name>
{
	list_size $1
}


# Copy set 1 into set 2
set_copy() # Args: <set1_name> <set2_name>
{
	list_copy "$1" "$2"
}

set_insert() # Args: <set_name> <item>
{
	[ $# -lt 2 ] && return 1

	local SET_NAME=$1
	array_compact $SET_NAME	
	local size=$(set_size $SET_NAME)

	shift
	
	while [ -n "$1" ]; do
		if ! set_contains $SET_NAME "$1"; then 
			list_add "$SET_NAME" "$1"
		fi
		shift
	done
}

set_contains() # Args: <set_name> <item>
{
	list_contains "$1" "$2"
}

set_get_index_of() # Args: <list_name> <item>
{
	[ -z "$1" ] && return 1
	
	local LIST_NAME=$1
	array_compact $LIST_NAME
	
	local size=$(list_size $LIST_NAME)
	local i=0
	while [ $i -lt $size ]; do
		eval ARG="\${$LIST_NAME[$i]}"
		if [ "$2" == "$ARG" ]; then
			echo $i
			return 0
		fi
		let i=$i+1
	done

	echo "-1"
	return 1
}

set_remove() # Args: <set_name> <item>
{
	list_remove "$1" "$2"
}

# Compact array positions
set_print() # Args: <array_name>
{
	list_print "$1"
}

set_to_string()
{
	list_to_string $1
}

string_to_set()
{
	string_to_list $1
}

