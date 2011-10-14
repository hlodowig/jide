__jide_completion()
{
	local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

	common_opts="--help -h --project -p -D --project-discovery"
	commands="init info config compile run clean archive delete"
	
	opts="$commands $common_opts"
	
	case "${prev}" in
		jide)
			COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
		 	return 0;;
		info)
		    COMPREPLY=( $(compgen -W "$common_opts" -- ${cur}) )
            return 0;;
        *) 	
 			COMPREPLY=( $(compgen -d ${cur}) )
        	#COMPREPLY=( $(compgen -A hostname ${cur}) )
			return 0;;
    esac

	
	
	return 0

}

complete -F __jide_completion jide

