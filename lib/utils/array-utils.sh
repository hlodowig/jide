
# Init array with value 
array_init() # Args: <array_name> <arg1> ...
{
	[ -z "$1" ] && return 1
	
	local ARRAY_NAME=$1
	eval "$ARRAY_NAME=()"
	shift
	
	local i=0
	while [ -n "$1" ]; do
		eval "$ARRAY_NAME[$i]=\"$1\""
		shift
		let i=$i+1
	done
}

# Clean array
array_clean() # Args: <array_name> <arg1> ...
{
	[ -z "$1" ] && return 1	
	eval "$1=()"
}

# Return size of array
array_size() # Args: <array_name>
{
	[ -z "$1" ] && return 1
	
	local ARRAY_NAME=$1
	eval echo "\${#$ARRAY_NAME[@]}"
}

array_is_empty() # Args: <array_name>
{
	local size=$(array_size $1)
	test $size -eq 0
}


# Copy array 1 into array 2
array_copy() # Args: <array1_name> <array_name2>
{
	[ $# -lt 2 ] && return 1
	
	eval "$2=(\${$1[@]})"
}

# Compact array positions
array_compact() # Args: <array_name>
{
	[ -z "$1" ] && return 1

	eval "$1=(\${$1[@]})"
}

array_get_value_at() # Args: <array_name> <item>
{
	[ $# -lt 2 ] && return 1
	local ARRAY_NAME=$1
	eval echo "\${$ARRAY_NAME[$2]}"

}

# Compact array positions
array_print() # Args: <array_name>
{
	[ -z "$1" ] && return 1
	
	local ARRAY_NAME=$1

	local i=0
	local elem_num=0
	
	eval local ARRAY_SIZE="\${#$ARRAY_NAME[@]}"

	while [ $elem_num -lt $ARRAY_SIZE ]; do
		eval ARG="\${$ARRAY_NAME[$i]}"
		while [ -z "$ARG" ]; do
			let i=$i+1		
			eval ARG="\${$ARRAY_NAME[$i]}"
		done

		eval echo "\$ARRAY_NAME[$i]=\$ARG"
		let elem_num=$elem_num+1
		let i=$i+1
	done	
}

array_to_string()
{
	[ -z "$1" ] && return 1

	local ARRAY_NAME=$1
	local OUT=""
	local i=0
	local elem_num=0
	
	eval local ARRAY_SIZE="\${#$ARRAY_NAME[@]}"

	while [ $elem_num -lt $ARRAY_SIZE ]; do
		eval ARG="\${$ARRAY_NAME[$i]}"
		if [ -n "$ARG" ]; then
			OUT="$OUT '$ARG'"
			let elem_num=$elem_num+1
		fi
		let i=$i+1
	done
	
	echo $OUT
}

string_to_array()
{
	[ -z "$1" ] && return 1

	local ARRAY_NAME=$1
	shift
	echo "$@"
	eval $ARRAY_NAME="(\"\$@\")"
}

