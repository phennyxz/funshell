#!/bin/bash
source "${BASH_SOURCE[0]%%\/*}/fa_dsourc.sh"

fa_dsourc fa_{ppar,range,rules}.sh

#timestamp;PID;user;line;code;log
function sf_err {
	echo "$(date +%F\;%T);$grau;$USER;$0;Process Erro: $$; exit code: $2." >&2
	return $2;
}

function fs_err {

	vl_context=${FUNCNAME[1]//main/}
	
	local -n vl_err=${vs_conf[${vl_context:+${vl_context}:}err]:=vs_err}
	local -n vl_log=${vs_conf[${vl_context:+${vl_context}:}log]:=vs_log}

	vl_err[actions]=";fl_ignore;fl_exit;${vl_err[actions]//;fl_ignore;fl_exit;/}"
	vl_err[priority]="${vl_err[priority]:-error, line, code}"
		
	declare -A err=(
		[time]="$(date +%F-%R)"		# timestamp
		[path]="$PWD"				# directori job
		[line]="${BASH_LINENO[0]}"	# line error
		[ppid]="$BASHPID"			# ppid
		[ctx]="ctx"
		[user]="$USER"				# user
		[pid]="$$"					# pid
		[last]="last"				# last_argument
        [all]="all"					# all_argument	
        [error]="error"				# err_return
        [orig]="${0##*/}"			# err_origin
        [code]="code"				# err_code defined by user
		[cmd]="cmd"
        [msg]="msg"				# err_message
        [proc]="$$"				# err_process
        [grau]='grau'			# err_severity
        [out]='out'				# err_out
		[act]='act'
		[delay]='delay'
		[att]='att'
		[grd]='grd'
		[full]='full'
	)
	
	if declare -f ${vl_log[handle]:=fs_log} > /dev/null ; then
		err[log]=${vl_log[handle]:=${fs_log[handle]}}
	else
		err[log]='sf_err'
	fi
		
	{ ct=${err[line]}; while read -r && ((ct--, ct > 0 )); do : ; done < ${BASH_SOURCE[1]}; err[full]="$REPLY"; } 2>/dev/null
	
	function fl_exec {
		
		local vl_act=${err[act]//act/fl_exit}
		
		if [[ $vl_act != ${err[cmd]} && -n ${vl_err[actions]//*;$vl_act;*/} ]]; then
			${err[log]} " function ${err[act]} not registred for erro trative"
			exit 2
		elif ! declare -f $vl_act >/dev/null; then
			${err[log]} " function $vl_act not registred for erro trative"
			exit 3
		fi
		
		if [[ ${err[grd]} == 'dg' ]]; then
			vl_err[defer]="${vl_err[defer]:+${vl_err[defer]};}$vl_act"
			${err[log]} "Error deferred for later handling."
			return 0
		fi
				
		if [[ ${err[grd]} == 'bg' ]]; then
			fl_aux &
		else
			fl_aux
		fi
	}
	
	function fl_aux {
		local vl_att=${err[att]//att/1}
		local vl_delay=${err[delay]//delay/0}
		local vl_inc=${vl_delay//*-*/(${vl_delay##*-}-${vl_delay%%-*})/vl_att+${vl_delay%%-*}}
		: $vl_delay
		for (( i=0;i<vl_att;++i )); do
			if ${vl_act//${err[cmd]}/${err[cmd]} ${err[all]}}; then
				vl_ret=$?
				${err[log]} "Repair succeeded."
				return $vl_ret
			fi
			${vl_delay:+ sleep $(($vl_inc*i))}
		done
		${err[log]} " function ${err[cmd]} unavailable for $vl_act"
		return 1		
	}

	
	function fl_ignore {
		${err[log]} "Error ignored (ignore)."
	}
	
	function fl_exit {
		${err[log]} "Halting due to critical error"
		${err[delay]:+ sleep ${err[delay]//delay/0}}
		exit "${err[error]//error/125}"
	}
		
	#vs_err[contexto:command]="seletor:valor;chave:valor;chave:valo+valor;cahve:valor|selector2:valor2....."	
	# Inicializa a pontuação máxima e a regra selecionada
	max_score=0
	declare -A vl_rule
	
	
	#faunção auxilia para dimisitrar os parametros passados.
	fa_ppar err "$@"
	
	# escolhe a regra mais relevante
	fa_rules err vl_err cmd vl_rule
	
	if [[ $? != 255 ]]; then
	
		# Controle de logging
	    ${err[log]} "${err[time]};${err[line]};${err[pid]};${err[user]};${err[code]};${err[msg]};Status: $status;Details: ${err[last]}"

		for key in "${!vl_rule[@]}"; do
		
			${err[$key]:+:} continue
			err[$key]=${err[$key]//$key/${vl_rule[$key]//cmd/${err[cmd]}}}
			
		done
		
		err[act]=${err[act]//ignore/fl_ignore}
		err[act]=${err[act]//halt/fl_exit}
		
	else
	
		# Controle de logging
	    ${err[log]} "${err[time]};${err[line]};${err[pid]};${err[user]};${err[code]};${err[msg]};Status: $status;Details: ${err[last]}"

		fl_exit
		
	fi
	
	fl_exec
	
}