# Funshell: A Biblioteca de Orquestração para Shell Scripts Modernos
## Slogan: Take the Fun, make it Shell—get funshell!
🎯 O que é o Funshell?
O Funshell é uma biblioteca de funções em shell script projetada para transformar scripts simples em aplicações de linha de comando robustas, seguras e modulares. Em vez de reescrever lógica complexa em cada projeto, o Funshell oferece um conjunto de ferramentas otimizadas para gerenciar tarefas críticas, permitindo que você se concentre na funcionalidade do seu programa.
Desenvolvido para o Bash 4+, o Funshell promove um estilo de programação mais funcional e declarativo, simplificando a orquestração e elevando a qualidade do seu código.
✨ Principais Características
 * Modularidade Robusta: Estrutura clara e organizada com módulos para cada finalidade, permitindo o carregamento seletivo de funcionalidades.
 * Gerenciamento de Erros e Logs: Abstrai a complexidade do tratamento de erros e da geração de logs detalhados, com informações como timestamp, PID, linha do erro e código de saída.
 * Foco em Segurança: Funções de sanitização (fs_sanit) e controle de comandos (fs_uncommand) protegem suas aplicações contra vulnerabilidades como injeção de comandos.
 * Orquestração Inteligente: O módulo fs_main orquestra o fluxo do programa de forma eficiente, interpretando opções de linha de comando e montando filas de execução de maneira declarativa.
 * Gerenciamento de Dependências: O fs_need verifica e gerencia as dependências do seu script, garantindo que o ambiente de execução esteja sempre preparado.
 * Performance Otimizada: Utiliza recursos avançados do Bash, como expansões de variáveis e arrays associativos, para minimizar o overhead e evitar o uso excessivo de chamadas a processos externos.
🚀 Uso Rápido
Aqui está um exemplo de como sua aplicação pode ser 
estruturada com a funshell:

#!/bin/bash

#Exemplo de uso da funshell

#Inclui o main da biblioteca

source funshell.sh

#Configura as opções do seu programa

#A funshell irá interpretar e rotear as ações

declare -gA vs_opt=(
    [default]='help 1'
    [--help|h]='msg help'
    [--install|i]='install'
    [--start|s]='start_service'
)

#Define uma ação para a opção 'install'

function install {

    # O fs_need verifica e instala dependências de forma inteligente

    fs_need --cmd 'git' --vrs '2.1.0'

    fs_need --cmd 'docker' --insta 'docker-ce'

    echo "Dependências verificadas e instaladas."

}

#Define uma ação para a opção 'start_service'

function start_service {

    echo "Iniciando o serviço..."

    #Lógica de inicialização do serviço aqui

}

#Inicia a orquestração do programa

fs_main "$@"

📂 Estrutura do Projeto
 * fs_*.sh: Módulos principais de orquestração (e.g., fs_main, fs_err, fs_log).
 * fa_*.sh: Módulos auxiliares de suporte (e.g., fa_rules, fa_parse, fa_range).
 * funshell.sh: Arquivo principal que inclui todos os módulos necessários.
 * README.md: Este arquivo.
🤝 Contribuições
Contribuições são bem-vindas! Se você encontrou um bug ou tem uma ideia para uma nova funcionalidade, sinta-se à vontade para abrir uma issue ou enviar um pull request.
📜 Licença
O Funshell está licenciado sob a licença GPL.
Autor: Wasley G. Araújo
