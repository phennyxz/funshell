#!/bin/bash

function fs_trap {
	local -n vl_trap=${vs_conf[trap]:=vs_trap}
	
	for signal in ${!vl_trap[@]}; do
		if ! trap -p $signal 2>/dev/null; then
			echo "a chave $signal não é um sinal valido" >&2
			exit 1
		fi
		for act in ${vl_trap[$signal]//;/ }; do
			if ! declare -f ${act%% *} >/dev/null; then
				echo "a função $signal não esta definida" >&2
				exit 2
			fi
		done
		trap "{ ${vl_trap[$signal]}; }" $signal
	done
}