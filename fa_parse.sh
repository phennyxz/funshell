#!/bin/bash

# Função fa_parse: Expande uma string substituindo ocorrências de [chave] com os valores da array correspondente.
function fa_parse {
    local -n array=$1   # Nome da array associativa passada como argumento
    local -n str=$2     # String que será modificada

    for key in "${!array[@]}"; do
        # Substitui [key] por ${array[key]} na string
        str="${str//\[$key\]/${array[$key]}}"
    done
}