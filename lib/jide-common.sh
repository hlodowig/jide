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
 
### COMMON FUNCTION ### 
 
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



### END COMMON FUNCTION  ###

