#!/bin/bash

function fs_uncommand_p {
    # Lista de comandos permitidos (exemplo)
	[[ -n ${#vs_conf[@]} ]] || declare -g -A vs_conf
    local -n vl_command_allow=${vs_conf[uncommand]:=vs_uncommand}
	local allowed=" ${vl_command_allow[@]} "
	
	while (($#)); do

		#captura a referencia para a variavel
		local -n cmd=$1

		#verifica se o comando esta na lista
		verify=${allowed//* ${cmd//[:[space]:]/} *}

		#se o comando estive na lista então vai para o proximo
		${verify:+ shift }
		${verify:+ continue }

		#delata a variavel e a referencia
		unset cmd
		shift
	done
}

function fs_uncommand {
    # Lista de comandos permitidos (exemplo)
	if [[ -n ${#vs_conf[@]} ]]; then
		declare -g -A vs_conf[uncommand]=vs_uncommand
	fi
    local -n vl_command_allow=${vs_conf[uncommand]}
	
	while (($#)); do

		#captura a referencia para a variavel
		local -n cmd=$1
		local allow
		
		#percorrer a lista de permitidos
		for verify in ${vl_command_allow[@]}; do
			[[ ${verify} == ${cmd//[:[space]:]/} ]] && allow=true
		done

			[[ -n allow ]] && unset cmd
		shift
	done
}
