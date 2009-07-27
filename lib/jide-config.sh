#
# jide-config.sh
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
 
 
 
jide_help_config() 
{
	#TODO
	echo "HELP CONFIG"
}

jide_config() 
{
#	echo "JIDE CONFIGURATION"
	
#	JIDE_SCRIPT=$(get_absolute_path $JIDE_PROGNAME)

	
#	echo "JIDE_SCRIPT=$JIDE_SCRIPT"
#	echo "JIDE_HOME=$JIDE_HOME"
	
	if [ -n "$1" ]; then	
		if [ -f "$1" ]; then
			#echo "Configuration file: $1"	
			source $1
		else
			print_error "Configuration file: $1 not found"; exit 2;
		fi
	else
		for cfile in "$JIDE_CONFIGFILE" \
		             "$JIDE_HOME/config/$JIDE_CONFIGFILE" \
		             "/etc/jide/$JIDE_CONFIGFILE" \
		             "/usr/local/etc/jide/$JIDE_CONFIGFILE"
		do
			if [ -f "$cfile" ]; then
				#echo "Configuration file: $cfile"	
				source $cfile
				break	
			fi
		done
	fi
	
	cd $JIDE_PROJECT_HOME

	if [ -f "$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_CONFIG_FILE" ]; then
		echo "Configuration file: $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_CONFIG_FILE"	
		source $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_CONFIG_FILE
	fi
	
	return 0;
}

