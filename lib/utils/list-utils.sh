
# Init list with value 
list_init() # Args: <list_name> <arg1> ...
{
	array_init $*
}

# Clean list
list_clean() # Args: <list_name>
{
	array_clean $1
}

# Return size of list
list_size() # Args: <list_name>
{
	array_size $1
}


# Copy list 1 into list 2
list_copy() # Args: <list1_name> <list2_name>
{
	[ $# -lt 2 ] && return 1
	
	eval "$2=(\${$1[@]})"
}

list_add() # Args: <list_name> <item>
{
	[ $# -lt 2 ] && return 1
	
	local LIST_NAME=$1
	array_compact $LIST_NAME	
	local size=$(list_size $LIST_NAME)

	shift
	
	while [ -n "$1" ]; do
		eval "$LIST_NAME[$size]=\"$1\""
		size=$(list_size $LIST_NAME)
		shift
	done
}

list_contains() # Args: <list_name> <item>
{
	[ -z "$1" ] && return 1
	
	local LIST_NAME=$1
	array_compact $LIST_NAME
	
	local size=$(list_size $LIST_NAME)
	local i=0
	while [ $i -lt $size ]; do
		eval ARG="\${$LIST_NAME[$i]}"
		[ "$2" == "$ARG" ] && return 0
		let i=$i+1
	done

	return 1
}

list_remove() # Args: <list_name> <item>
{
	[ $# -lt 2 ] && return 1
	
	local LIST_NAME=$1
	array_compact $LIST_NAME

	local size=$(list_size $LIST_NAME)
	local i=0
	while [ $i -lt $size ]; do
		eval ARG="\${$LIST_NAME[$i]}"

		if [ "$2" == "$ARG" ]; then
			eval "$LIST_NAME[$i]=\"\""
			array_compact $LIST_NAME
			return 0
		fi
		let i=$i+1
	done

	return 1
}

# Compact array positions
list_print() # Args: <array_name>
{
	[ -z "$1" ] && return 1
	
	echo "( $(list_to_string $1) )"
}

list_to_string()
{
	array_to_string $1
}

string_to_list()
{
	string_to_array $*
}

