#!/bin/bash
source ../fa_funcallscan.sh
source ../fa_fundefscan.sh
source ../fa_ppar.sh

function fs_dsource {
	vl_context=${FUNCNAME[2]//main/}
	
	local -n vl_source=${vs_conf[${vl_context:+${vl_context}:}source]:=vs_source}
	
	declare -A sourc=(
		[mode]='mode'
		[path]='path'
		[file]='file'
		[pre]='pre'
		[ext]='ext'
		[funcs]=''
		[fonts]=''
		[default]='default'
	)

	fa_ppar vl_source "$@"
	
	sourc[file]=${sourc[file]//file/${0}}
	sourc[path]=${sourc[path]//path/${0%%[^/]*}}
	fa_funcallscan sourc[funcs] ${sourc[file]}
	
	for search in ${sourc[path]:+ ${sourc[path]}/}*${sourc[ext]/ext/.sh}; do
		if fa_fundefscan sourc[funcs] $search; then
			if [[ -n "${sourc[fonts]//* $search */}" || -z "${sourc[fonts]}" ]]; then
				sourc[fonts]="${sourc[fonts]} $search "
			fi
		fi
		[[ -z "${sourc[funcs]// /}" ]] && break
	done

	for sou in ${sourc[fonts]}; do
		source $sou
	done
}

# Executa apenas se chamado diretamente
if [[ "${BASH_SOURCE[1]}" == "$0" ]]; then
    fs_dsource
fi