
jide_help_delete() 
{
	#TODO
	echo "HELP DELETE"
}

jide_delete() 
{
	echo "COMMAND='delete'"
	echo "ARGS=$*"
	
	cd $JIDE_PROJECT_HOME
	
	rm -r $JIDE_PROJECT_CONFIG_DIR
}
