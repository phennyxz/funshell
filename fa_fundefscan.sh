#!/bin/bash

function fa_fundefscan {
	local -n list=$1
	[[ -f $2 ]] || return 127
	
	while read -r line; do
		[[ -z "${line%%* \{}" ]] || continue
		[[ "$line" =~ ^function[[:space:]].*[[:space:]]\{$ ]] ||\
		[[ "$line" =~ ^[a-zA-Z_].*\(\)[[:space:]]?\{ ]] || continue
			term=${line#function }
			term=${term%%\(*}
			term=${term%% *}
			t=${list//* $term */}
			${t:+ continue}
			list=${list// $term / }
			it=0
	done < $2
	return ${it:-1}
}