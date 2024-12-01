#!/bin/bash
source "${BASH_SOURCE[0]%%\/*}/fa_dsourc.sh"

fa_dsourc fa_{ppar,rules,parse}.sh

# Função fs_log: Loga erros com timestamp, PID, usuário, linha do erro, código de erro e mensagem
function fs_log {
    : 'forma que é chamada: fs_log --last $_ --error $? --cmd cmd --code code --msg "unknow fails" "$@" '
	
    vl_context=${FUNCNAME[1]//main/}
	
    local -n vl_log=${vs_conf[${vl_context:+${vl_context}:}log]:=vs_log}

	declare -A log=(
        [last]="last"          				# last_argument
        [all]="all"           				# all_argument
        [error]="error"         				# cmd_return
        [line]="${BASH_LINENO[0]}"			# cmd_line
        [orig]="${0##*/}"  				# log_origin
        [code]="code"          				# log_code
        [msg]="msg"       				# log_message
        [proc]="$$"       				# log_process
		[time]="$(date +%F\;%T)"			# log_timestamp
		[user]="$USER"					# cmd_user
        [grau]='grau'			    	# log_severity
        [media]='media'  			     	# log_action
        [out]='out'       				# log_out
		[ctxt]='ctxt'
		[full]='full'
		[cmd]='cmd'
		[file]=${vl_log[file]:=${0##*\/}.log} # file log
		[host]=${vl_log[host]:=host}
		[path]=${vl_log[path]:=/var/log}	# directorio log
        [rule]='rule'
		[imax]='imax'
		[term]=''
    )
    
	declare -A vl_rules
	
	#gerencia os param passados
	fa_ppar log "$@"
	    
	fa_rules log vl_log error log
		
	${vl_log[patt]:+ fa_parse log vl_msg}
	
	vl_msg=${vl_log[patt]:-${log[time]}; ${log[orig]}; ${log[user]}; ${log[grau]}; PID:${log[proc]}; Line:${log[line]}; Exit Code:${log[error]}; Message: ${log[msg]:-'No Details'}}
	 
    if [[ ! -d ${log[path]} ]] || ! mkdir -p ${log[path]}; then
            echo "Erro: não foi possível criar o diretório: ${log[path]}"
            exit 1
    fi
    
	#definir caminho completo do arquivo de log
	file_path="${log[path]}/${log[file]}"
	
	# não tendo permisão de escrita, tenta criar arquivo de log até atingir o limite de incremento
	inc=''	# vazia, para primeiro tentar cria o arquivo original.
	
	while [[ ! -w "$file_path" ]]; do
		vl_log[file]="${log[file]//./${inc:+_$inc}.}"
		log[file]="${vl_log[file]}"
		file_path="${log[path]}/${log[file]}"
		
		if >> $file_path; then
			break
			log[file]=$file_path
		elif [[ $inc -gt ${log[imax]//imax/3} ]]; then
			echo "Erro: não foi possível escrever no arquivo de log: $file_path"
			exit 1
		fi
		
		((inc+=1))
	done
	
	# trabalhando esse sessão.
	for mdia in ${log[media]//,/ }; do
		ve_out=${log[$mdia]//media/term}
		${ve_out:+echo "$vl_msg"}: 2>> ${ve_out:-/dev/null} >&2
		${ve_out:+continue}
		echo "$vl_msg" >&2
		
    done
	
    # Finaliza o script com o código de erro que o comando que falhou passo
	if [[ ${log[out]} == "exit" ]]; then
		exit ${log[error]}
	else
		return ${log[error]}
	fi
	
}
