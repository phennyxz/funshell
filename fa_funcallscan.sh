#!/bin/bash

function fa_funcallscan {
	local -n visto=$1
  # Ler o script linha por linha
	while read -r line; do
		line="${line//[\]\}\)\(\{\[|&;]/$'\n'$a$'\n'}"
		line=${line//#*/}
		line=${line//for * in/for}
		line=${line//read */read}
		line=${line//declare */}

		for wrd in ${line}; do
			t=${wrd//[^a-zA-Z_]*/}
			${t:+ :} continue
			if ! compgen -c "${wrd//*[\"\'\`\}$=&|]*/do}" >/dev/null; then
				if ! compgen -k "$wrd" >/dev/null; then
					if [[ -n "${visto//* $wrd */}" || -z "$visto" ]]; then
						visto="${visto:- }$wrd "
					fi
				fi
			fi
		done
	done < $2
}
