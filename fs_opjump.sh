#!/bin/bash
#pula opções passa ao orquestrador a partir de modulos e submodulos
function fa_opjump {
	vl_jmp=${1//[^0-9]}
	declare -g vs_jump=${vl_jmp:-1}
}