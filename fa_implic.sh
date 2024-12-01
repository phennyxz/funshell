#!/bin/bash
source "${BASH_SOURCE[0]%%\/*}/fa_range.sh"

function fa_implic {
	local item=$1
	local -n array=$2
	local -i value=0
		
	# percores as regras colocando [ord] para casos de omisão
	for ve_verif in ${array//|/ }; do
		ve_item=${ve_verif//*;$item:/}
		ve_item=${ve_ord//;*/}

		((value++))

		#verifica se tem um numero no intervalo ja usado.
		if fa_range "$ve_item" "0-$value" ; then

			#desfaz a troca de ord do automatico definido anteriomente e o atual definido pela regra.
			array="${array//$item:$ve_item;/$item:$value;}"

		fi

		#confirma se é numero definido para ord nessa regra 
		fa_range "$ve_item" "$ve_item" && continue

		#caso não tenha ord definido atribui o proximo numero livre.
		array="${array//$ve_verif/$item:$value;$ve_verif}"

	done

}