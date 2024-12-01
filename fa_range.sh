#!/bin/bash

# Função para verificar se um número está dentro de um intervalo específico
function fa_range {
	${1:+: no} return 2
	${2:+: no} return 3
	local item=${1//*[^0-9]*/0}      # Extrai apenas números do argumento item, substitui por "0" se houver caracteres
	local range=${2//*[^0-9-]*/$item+1}
	
	# Verifica se o item está fora do intervalo especificado; retorna 1 se estiver fora e 0 se estiver dentro
	if (( $item < ${range%%-*} )) || (( $item > ${range##*-} )); then
		return 1
	fi
	return 0
}