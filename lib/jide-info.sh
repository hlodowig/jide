
jide_help_info() 
{
	#TODO
	echo "HELP INFO"
}

jide_info() 
{
	
	cd $JIDE_PROJECT_HOME
	
	if [ ! -d $JIDE_PROJECT_CONFIG_DIR ]; then
		echo "JIDE: Not project directory"
		exit -1
	fi
	
	echo "JIDE Project Info"
	echo
	printf "[*] %-20s %s\n" "Name"          "$(get_project_property JIDE_PROJECT_NAME)"
	printf "[*] %-20s %s\n" "Description"   "$(get_project_property JIDE_PROJECT_DESC)"
	printf "[*] %-20s %s\n" "Author"        "$(get_project_property JIDE_PROJECT_AUTHOR)"
	printf "[*] %-20s %s\n" "Creation time" "$(get_project_property JIDE_PROJECT_CTIME)"
	printf "[*] %-20s %s\n" "Project Path" "$JIDE_PROJECT_HOME"	
	printf "[*] %-20s %s\n" "Source  Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_SRCDIR"
	printf "[*] %-20s %s\n" "Classes Path" "$JIDE_PROJECT_HOME/$JIDE_PROJECT_CLASSDIR"
	echo
	
	exit $?
}

