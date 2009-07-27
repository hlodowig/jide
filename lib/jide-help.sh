
jide_help() {
	if [ -z "$1" ]; then
		echo "HELP"
	else
		case $1 in
			init|compile|run|clean|delete|info|archive) jide_help_$1;;
			*) jide_help;;
		esac
	fi
}

