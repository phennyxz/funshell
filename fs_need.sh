#!/bin/bash
source "${BASH_SOURCE[0]%%\/*}/fa_dsourc.sh"

fa_dsourc fa_{ppar,range,rules,implic}.sh

function fs_need {
    # Identifica o contexto baseado na função chamadora
    vl_context=${FUNCNAME[1]//main/}
    # Define as necessidades com base na configuração ou no padrão
    local -n vl_need=${vs_conf[${vl_context:+${vl_context}:}need]:=vs_need}
    vl_need[priority]='ord'
    declare -A ve_need

    # Mapeia os parâmetros padrão
    local -A need=(
        [install]=${vl_need[install]}
        [cmd]='cmd'
        [vrs]='vrs'
        [path]='path'
        [check]='check'
        [dload]='dload'
        [instd]='instd'
        [insta]='insta'
        [msge]='msge'
        [msga]='msga'
        [ord]='ord'
    )
	
	
    # Função auxiliar para processar os parâmetros passados (ex: fs_need --cmd xx --bkp ...)
    fa_ppar need "$@"

    # Define chaves a serem ignoradas no processamento
    local vl_ignor=':;priority;handle;install;path;init;call;time;pukey;prkey;:'
    for ve_cmd in "${!vl_need[@]}"; do
		
        # Ignora chaves de controle interno
        ve_ignor=${vl_ignor//*;$ve_cmd;*/}
        ${ve_ignor:+:} continue

        # Verifica se o comando já está disponível
        command -v "${ve_cmd}" &>/dev/null && continue

        # Força valor implícito para a prioridade (ord) nas regras
        fa_implic ord vl_need["$ve_cmd"]
		
		need[cmd]=$ve_cmd

        # Determina o número de regras aplicáveis
        ve_lot=${vl_need[$ve_cmd]//[^|]/}
        ve_lot=$((${#ve_lot}+1))
        local -i ve_ord=1

        while ((ve_ord <= ve_lot)); do
			need[ord]=$ve_ord
            # Aplica regras e trata os parâmetros em ve_need
            fa_rules need vl_need cmd ve_need

            # Verifica se o programa está instalado com uma versão válida
            if [[ -n ${ve_need[vrs]//*\/*/} ]]; then
                if fa_range "$(${ve_need[cmd]} --version 2>/dev/null)" "${ve_need[vrs]}"; then
                    break
                fi
            elif command -v "${ve_need[cmd]}" &>/dev/null; then
                break
            fi

            # Tenta instalar o comando, se uma chave de instalação for definida
            if [[ -n ${ve_need[insta]} ]]; then
                if ${vl_need[install]//cmd/${ve_need[insta]}}; then
                    break
                fi
            elif [[ -n ${ve_need[dload]} ]]; then
                # Tenta fazer o download e instalar, se uma chave de download for definida
                if ${ve_need[instd]}; then
                    break
                fi
            fi

            ((ve_ord++))
        done

        # Se a instalação falhar após todas as tentativas, verifica fallback ou termina com erro
		if [[ $ve_ord -gt $ve_lot ]]; then
			exit 127
        elif [[ ${ve_need[cmd]} != $ve_cmd ]] && [[ -n ${ve_need[parse]} ]]; then
			: ${ve_need[parse]//:/]=}
			opt="[${_//;/ [}"
						
			source /dev/stdin <<< "function $ve_cmd"'() {
					declare -A opts=( '"$opt"' );
					all="$@"
					for opt in ${!opts[@]}; do
						all="${all//$opt/${opts[$opt]}}";
					done;
					'"$ve_cmd"' $all; 
				};'
							
		else
			source /dev/stdin <<< "
			function $ve_cmd {
				${ve_need[cmd]} \$@
			}"
			
		fi
		
    done

}