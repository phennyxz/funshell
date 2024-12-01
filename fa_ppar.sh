#!/bin/bash

# Função para validar e atualizar parâmetros passados em pares, verificando se cada par é válido dentro de um conjunto definido.

function fa_ppar {
	local -n opts=$1   # Recebe um array associativo como argumento, passado por referência
	shift              # Remove o primeiro argumento (opts), deixando os parâmetros restantes
		
	# Verifica se o número de argumentos é par; caso contrário, exibe uma mensagem de erro
	if (($# % 2)); then
		echo "parâmetros devem ser fornecidos em pares" >&2
		return 6
	fi

	# Itera pelos argumentos em pares (chave-valor)
	while [[ -n $1 ]]; do
		key="${1//--/}"  # Remove prefixo "--" da chave
		
		# Verifica se a chave existe no array de opções, caso contrário, exibe uma mensagem de erro
		if [[ -z "${opts[$key]}" ]]; then
			echo "parâmetro inexistente" >&2
			return 5
		fi
		
		# Substitui o valor da chave no array de opções
		opts[$key]="${opts[$key]//$key/$2}"
		shift 2   # Avança para o próximo par chave-valor
	done
}
