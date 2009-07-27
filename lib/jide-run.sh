jide_help_run() 
{
	#TODO
	echo "HELP RUN"
	echo "$JIDE_PROGNAME compile [-n|--name <project_name>] [-d|--description <project_description>] [-s | --sourcepath <path>] [-c | --classpath <path>] [-f|--force]"
}

jide_run() 
{
	echo "COMMAND='run'"
	echo "ARGS=$*"

	cd $JIDE_PROJECT_HOME
	
	if [ ! -d $JIDE_PROJECT_CONFIG_DIR ]; then
		echo "JIDE: Not project directory"
		exit -1
	fi

	if [ ! -f $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES ]; then
		echo "Project not compiled"
		exit -1
	else
		local mp_num=$(wc -l $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES | cut -d' ' -f1)
		
		if [ $mp_num -eq 0 ]; then
			echo "Thera are not main class in this project"
			exit -1		
		fi	
	fi

	if [ -z "$*" ]; then
		__print_main_classes
		exit 0
	fi
	
	for prog in $*; do
		__run $prog
	done
	
	exit $?
}


