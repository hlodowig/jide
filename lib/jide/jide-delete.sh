#
# jide-delete.sh
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
 
 
 
jide_help_delete() 
{
	#TODO
	echo "HELP DELETE"
}

jide_delete()
{
	#echo "COMMAND='delete'"
	#echo "ARGS=$*"
	
	cd $JIDE_PROJECT_HOME
	
	__jide_is_project_dir || exit 1
		
	__jide_project_clean_sourcedir
	rm "$JIDE_PROJECT_SRCDIR/.jide-project" 2> /dev/null
	__jide_project_clean_classdir
	rm -r $JIDE_PROJECT_CONFIG_DIR

}
