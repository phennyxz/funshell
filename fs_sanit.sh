#!/bin/bash

function fs_sanit {
   # Define os caracteres a serem removidos, permitindo sobreposição via vs_sanit_char
   # usuario pode tando redefinir os caracteres a ser removido como apenas definir caracteres que não precisa ser removido
    local vs_sanit_denny="${vs_sanit_char:-|><&;\$?!-}"
    local vs_sanit_denny="${vs_sanit_denny//[$vs_sanit_allow]/}"
    
    # Cria uma classe de caracteres para substituição
    local sanitize_pattern="[${vs_sanit_denny//./\\.}]"
    
    # Itera sobre todos os argumentos passados para a função
    while [[ $# -gt 0 ]]; do
        # Cria uma referência de nome para a variável cujo nome é passado como argumento
        declare -n input_ref="$1"
        
        # Remove caracteres especiais e redirecionadores
        input_ref="${input_ref//[$sanitize_pattern]/}"
        
        # Valida o comando sanitizado
        fs_uncommand "$input_ref"
        
        # Avança para o próximo argumento
        shift
    done
}