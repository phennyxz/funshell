#!/bin/bash
source "${BASH_SOURCE[0]%%\/*}/fa_range.sh"

# Função que aplica regras definidas em um conjunto de opções, utilizando uma configuração de prioridades e seletores
function fa_rules {
	local -n opts=$1      # Array de opções passado por referência
	local -n conf=$2      # Configurações de regras passadas por referência
	local key="$3"        # Chave específica para aplicar as regras
	local -n out=$4       # Array de saída para armazenar as regras aplicadas
	local max_score=0     # Inicializa a pontuação máxima para selecionar a regra mais relevante
	
	# Define a ordem de prioridade dos seletores
	: ${conf[priority]:=cmd}
	vt_orden=( ${conf[priority]//,/ } )	
	
	# Itera por cada regra associada à chave especificada, separadas por "|"
	all_rules=${conf[${vl_context:+$vl_context:}${opts[$key]}]// /·_·}
	for rules in ${all_rules//|/ }; do
		: ${rules//:/]=}  # Converte a regra em um formato de array associativo - passo 1
		declare -A "rule=( [${_//;/ [} )"  # Passo 2 da conversão e Declara a regra como um array associativo
		score=0              # Inicializa a pontuação da regra atual
		
		# Itera pelos seletores, verificando se correspondem ao valor da regra
		for selec in ${vt_orden[@]}; do
			${rule[$selec]:+:} continue   # Pula se o seletor não estiver na regra atual
			
			# Verifica se o valor de 'opts' bate com a regra ou se está dentro de um intervalo permitido
			if [[ ${opts[$selec]} == ${rule[$selec]:-0} ]] || fa_range "${opts[$selec]}" "${rule[$selec]}"; then
				((score++))
			fi	
		done
		
		# Seleciona a regra com maior pontuação ou uma que alcance a pontuação máxima
		if (( score > max_score )); then
			max_score=$score
			for opt in ${!rule[@]}; do
				out[$opt]=${rule[$opt]//·_·/ }  # Armazena a regra de maior pontuação no array de saída
			done
			(( score == ${#vt_orden[@]} )) && return 0  # Retorna se atingir pontuação total
		fi
	done
	
	# Retorna 255 se nenhuma regra foi aplicada ou retorna a pontuação máxima
	if (( max_score > 0 )); then
		return $max_score
	else
		return 255
	fi
}
