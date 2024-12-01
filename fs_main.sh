#!/bin/bash
#a funshell function
#work in vs_opt=( [default]='help 1' [start]='run $@' [--help|h]='msg help' [--version|v]='msg version' [--verbos|V]='declare verbos' [-e]='exemple' [--end]='end 0' )

function fs_main {
	
	#verifica se alguma configuração foi cirar, se não inicia ela
	[[ -z ${vs_conf[@]} ]] && declare -gA vs_conf

	#local fs_opshift='set -- fs_opjump $1 <<<'

	#referencia para as variaveis do funshell verificando se foram reconfiguradas
	local -n vl_opt="${vs_conf[${FUNCNAME[1]:+${FUNCNAME[1]}:}opt]:=vs_opt}"
    local vl_err="${vs_conf[err]:=vs_err}"
	local vl_shorts="${vs_conf[shorts]:=vs_shorts}"
	local vl_arg_indicator="${vs_opt[arg_indicator]:=:}"
	
	if declare -f ${vl_err[handle]} > /dev/null ; then
		local fl_err="${vs_err[handle]}"
	else
		local fs_err=":"
	fi
	
	
	#verifica se as opções curtas foram desativadas ou chama a fs_shorts
	if [[ -z "${vl_shorts[use]}" ]]; then
		fa_shorts || $fl_err $? "$0: $$ error ao tentar criar opções curtas para o programa"
	fi
	
	#verifica os parametros e monta a fila de opções e parametros para execução baseado foi passado na chamada do programa.
	while [[ -n "$1" ]]; do

		# verifise existe a opção passada
		if [[ -n ${vs_opt[$1]} ]]; then
			# execulta a opção ou retorna um erro associado
			${vl_opt[$1]/\$?/$@} || $fl_err $? ${vs_err[$1]:-"$0: $$ error desconhecido"}
	
		# veirifca se é uma cadeia de opções curtas agrupadas
		elif [[ ${1:0:1} == '-' && ${#1} -gt 2 && ${1:1:1} != '-' ]]; then
		
			#variavel auxiliar de trabalhos do agrupamento de opções curtas.
			vl_next_arg=( ${@##*$1} )
			vl_used_arg=''
			vl_group="${1/-}"
			vl_ord=0

			#itera sobre cada caractere da cadeia de opções curtas para validar e expandir
			for ((it=0;it<${#vl_group};it++)); do

				#verificando opções aninhadas que recebem argumentos
				if [[ "${vl_group:$it:1}" == "$vl_arg_indicator" ]]; then
					[[ -n ${vl_next_arg[$vl_ord]} ]] || $fl_err $? ${vs_err[${vl_param[$vl_ord-1]}]:-"$0: $$ falta de argumento $@"}
					vl_param[$it]=${vl_next_arg[$vl_ord]}
					vl_used_arg+="${vl_next_arg[$vl_ord]:+ ${vl_next_arg[$vl_ord]}}"
					
					((vl_ord+=1))
					
				else
					#variavel auxiliar de trabalhos da opções curta.
					vl_param[$it]="-${vl_group:$it:1}"
					
				fi
				
			done
			
			# rescreve a fila de opções parametros passada na chamada elimindado a opção que tratamos.
			vl_optoriginal="${@}"
			set $$ ${vl_optoriginal/$1$vl_used_arg/${vl_param[@]}}

		else
			${vl_opt[default]/\$?/$@} || $fl_err $? ${vl_err[default]:-"$0: $$ error desconhecido" }

		fi
		shift ${vs_jump:-1};
		${vs_jump:+ unset vs_jump}	
#		((cnt+=1, cnt > 6)) && exit

	done
	
	#chama a função inicial de processamento apos organizar a fila de opções e parametros
	${vs_opt[start]:- : fim} || $fl_err $? ${vs_err[start]:-"$0: $$ error desconhecido"}

}