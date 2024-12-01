#!/bin/bash
#fa_shorts.sh

function fa_shorts {

	#varaivel auxiliar
	local vl_f1
	
	#referencia para as variaveis do funshell verificando se foram reconfiguradas
	local -n vl_opt="${vs_conf[opt]:=vs_opt}"
	local -n vl_shorts="${vs_conf[shorts]:=vs_shorts}"
	
	local vl_dtr="${vl_shorts[delimiter]:=|}"
		# percorre todas as opções disponiveis criando opções curtas para os parametros ja sinalizados.
		for vl_f1 in ${!vl_opt[@]}; do
		
			#verifica se a opão atual tem o delimitar
			[[ -n "${vl_f1//*$vl_dtr*}" ]] && continue
			
			#criar um entrada para a opção curta sinalizada diretamente.
			vl_opt["-${vl_f1//*$vl_dtr}"]="${vl_opt[$vl_f1]}"
			
			#criar um entrada para a opção longa sinalizada diretamente.
			vl_opt["${vl_f1//$vl_dtr*}"]="${vl_opt[$vl_f1]}"
			
			# remove a entrada original com delimitador
			unset vl_opt[${vl_f1}]
		done
	: ${!vl_opt[@]}
}
