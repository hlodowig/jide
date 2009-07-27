
jide_help_compile() 
{
	#TODO
	echo "HELP COMPILE"
	echo "$JIDE_PROGNAME compile [-s | --sourcepath <path>] [-c | --classpath <path>]"

}

jide_compile() 
{
	#TODO
	echo "COMMAND='compile'"
	echo "ARGS=$*"
	
	cd $JIDE_PROJECT_HOME

	if [ $# -ne 0 ]; then

		# Si raccoglie la stringa generata da getopt.
		local ARGS=$(getopt -o ?hs:c: -l sourcepath:,classpath:,help  -- "$@" 2> /dev/null)

		# Si trasferisce nei parametri $1, $2,...
		eval set -- "$ARGS"


		while true ; do
			case "$1" in
				-s|--sourcepath) JIDE_PROJECT_SRCDIR=$2;   shift 2;;
				-c|--classpath)  JIDE_PROJECT_CLASSDIR=$2; shift 2;;
				--) shift; break;;
				-h|-?|--help) jide_help_compile; exit 0;;
				*) shift;;
			esac
		done	
	fi
	
	if [ ! -d $JIDE_PROJECT_CLASSDIR ]; then
		echo "Create classes dir: $JIDE_PROJECT_CLASSDIR"
		mkdir $JIDE_PROJECT_CLASSDIR
	fi

	rm -r $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES 2> /dev/null
	touch $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES
	rm -r $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES 2> /dev/null
	touch $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVE_SOURCES
	
	local JDIRS="$(ls -R $JIDE_PROJECT_SRCDIR | grep : | cut -d: -f1)"
	local JFILES=""
	
	echo $JDIRS
	
	for dir in $JDIRS; do
		JFILES="$(ls $dir/*.java 2>/dev/null) $JFILES"
	done

	#echo -e $JFILES
	
	local cf=0
	
	if [ -n "$JFILES" ]; then
		for jfile in $JFILES; do
			echo $jfile >> $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_JAVA_SOURCES
			
			cfile=$(get_classfile $jfile $JIDE_PROJECT_SRCDIR $JIDE_PROJECT_CLASSDIR)
			if [ -n "$(grep "void main" $jfile)" ]; then
				echo "Trovato main in $jfile"
				get_classname $jfile $JIDE_PROJECT_SRCDIR >> $JIDE_PROJECT_CONFIG_DIR/$JIDE_PROJECT_MAIN_CLASSES
			fi
			
			if [ ! -f "$cfile" ] || [ $(get_file_mod_time $jfile) -gt $(get_file_mod_time $cfile) ]; then
				echo "Compile: $jfile --> $cfile"
				$JAVA_COMPILER -sourcepath $JIDE_PROJECT_SRCDIR -d $JIDE_PROJECT_CLASSDIR $jfile
				let cf=$cf+1
			fi
		done
	else 
		echo "No found java source files"
	fi

	printf "Compiled %d files\n" $cf

	exit $?
}

