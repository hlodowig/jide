#
# jide-info.sh
# This file is part of JIDE
#
# Copyright (C) 2009 - Luigi Capraro
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
 
 
 

jide_help_info() 
{
	#TODO
	echo "HELP INFO"
}

jide_info() 
{
	cd 	$JIDE_PROJECT_HOME
	__jide_is_project_dir || exit 1
	
	echo "JIDE Project Info"
	echo
	printf "[*] %-20s %s\n" "Name"          "$(__jide_project_get_property JIDE_PROJECT_NAME)"
	printf "[*] %-20s %s\n" "Description"   "$(__jide_project_get_property JIDE_PROJECT_DESC)"
	printf "[*] %-20s %s\n" "Author"        "$(__jide_project_get_property JIDE_PROJECT_AUTHOR)"
	printf "[*] %-20s %s\n" "Creation time" "$(__jide_project_get_property JIDE_PROJECT_CTIME)"
	printf "[*] %-20s %s\n" "Project Path" "$(get_relative_path "$JIDE_PROJECT_HOME")"	
	printf "[*] %-20s %s\n" "Source  Path" "$(get_relative_path "$JIDE_PROJECT_HOME/$JIDE_PROJECT_SRCDIR")"
	printf "[*] %-20s %s\n" "Classes Path" "$(get_relative_path "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CLASSDIR")"
	echo
	
	exit $?
}

