
jide_help_config() 
{
	#TODO
	echo "HELP CONFIG"
}

jide_config() 
{
	echo "JIDE CONFIGURATION"
	
	JIDE_SCRIPT=$(get_absolute_path $JIDE_PROGNAME)
	JIDE_HOME=$(dirname $JIDE_SCRIPT)
	
	echo "JIDE_SCRIPT=$JIDE_SCRIPT"
	echo "JIDE_HOME=$JIDE_HOME"
	
	if [ -n "$1" ]; then	
		if [ -f "$1" ]; then
			echo "Configuration file: $1"	
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
				echo "Configuration file: $cfile"	
				source $cfile
				break	
			fi
		done
	fi
	
	echo
	
	cd $JIDE_PROJECT_HOME

	if [ -f "$JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_CONFIG_FILE" ]; then
		echo "Configuration file: $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_CONFIG_FILE"	
		source $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_CONFIG_FILE
	fi
	
	return 0;
}

