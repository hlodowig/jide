#
# utils.sh
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

get_var() 
{
	[ $# -lt 1 ] && return 1
	local VAR_VALUE
	eval  VAR_VALUE='$'"${1}"
	echo $VAR_VALUE
}

set_var() 
{
	[ $# -lt 1 ] && return 1
	local VARNAME=$1
	shift
	eval $VARNAME="'$*'"
}

read_var() 
{
	[ $# -lt 1 ] && return 1
	
	VARNAME=$1
	shift
	
	if [ -n "$*" ]; then
		echo -n "$*"
	else
		echo -n "$VARNAME="
	fi
	
	eval read "$VARNAME"
}

print_error() {
	echo -e "$0: ERROR: $*" >&2
}

get_boolean()
{
	if echo "$1" | grep -qE "(1|[Yy][Ee][Ss]|[Oo][Nn|Kk]|[Ee][Nn][Aa][Bb][Ll][Ee])"
	then
		echo "1"; return 0
	fi
		
	#echo "$1" | grep -qE "(0|[Nn][Oo]|[Oo][Ff][Ff]|[Dd][Ii][Ss][Aa][Bb][Ll][Ee])" && echo "0"; return 0
	echo 0
	return 1	
}

is_program_installed()
{
	which $1 > /dev/null 2> /dev/null
	return $?
}





