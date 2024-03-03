#!/bin/bash
# Nome: Vinicius Rodrigues
# Número: 
# Este proprama tem como finalidade resolver os problemas apresentados no TILBASH 2024
# O arquivo de Output será "ViniciusRodrigues-TILBASH-EN.log" e estará disponível na mesma pasta onde este script está sendo executado.
# Este script também estará disponível em " https://github.com/ViniGuiRodri?tab=repositories "


# Função para verificar se o script está sendo executado como root
verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Este script precisa ser executado como root!"
        exit 1
    fi
}

# Chamada da função para verificar se é root
verificar_root

# Variável para armazenar o tempo de início do script
tempo_inicio=$(date +%s)


nome_arquivo_log="ViniciusRodrigues-TILBASH-EN.log"
nome_arquivo_html="ViniciusRodrigues-TILBASH-EN.html"

# Inicializa o arquivo de log e o arquivo HTML
echo "Iniciando Script..." > "$nome_arquivo_log"
echo "<html><head><title>Relatório TILBASH 2024</title></head><body><h1>Relatório TILBASH 2024</h1><ul>" > "$nome_arquivo_html"


# Array para armazenar as escolhas do usuário
declare -a escolhas_usuario



# Função para exibir o menu
exibir_menu() {
    clear
    echo "==== Menu ===="
    echo "1. Listar Tentativas de Login Falhadas"
    echo "2. Listar Tentativas de Login Falhadas + Datas"
    echo "3. Filtragem pelo Número de Tentativas Falhadas"
    echo "4. Filtrar a Pesquisa por um Intervalo Temporal"
    echo "5. Cifra Histórico"
    echo "6. Opção 6"
    echo "7. Opção 7"
    echo "8. Opção 8"
    echo "9. Opção 9"
    echo "0. Sair"
    echo "=============="
}

# Função para sair do programa
Sair() {
    clear # Limpa a tela

    # Calcula o tempo decorrido desde o início do programa
    tempo_fim=$(date +%s)
    tempo_decorrido=$((tempo_fim - tempo_inicio))
    echo "Tempo decorrido desde o início do programa: $tempo_decorrido segundos."

    # Apresenta as opções tomadas pelo usuário durante essa sessão
    echo "Opções escolhidas durante a sessão: ${escolhas_usuario[*]}"

    # Adiciona as informações ao arquivo de log e ao relatório HTML
    echo "Tempo decorrido desde o início do programa: $tempo_decorrido segundos." >> "$nome_arquivo_log"
    echo "Opções escolhidas durante a sessão: ${escolhas_usuario[*]}" >> "$nome_arquivo_log"
    
    # Adiciona informações ao arquivo HTML e finaliza o arquivo
    echo "<li>Tempo decorrido desde o início do programa: $tempo_decorrido segundos.</li>" >> "$nome_arquivo_html"
    echo "<li>Opções escolhidas durante a sessão: ${escolhas_usuario[*]}</li></ul></body></html>" >> "$nome_arquivo_html"
    
    # Calcula a hash SHA1 do arquivo history.log.enc antes de sair
    Hashing "history.log.enc"
    
    exit
}

# Função para processar a escolha do usuário
processar_escolha() {
    read -p "Escolha uma opção (0 a 9): " escolha
    escolhas_usuario+=("$escolha") # Armazena a escolha do usuário
    case $escolha in
        1) opcao_um ;;
        2) opcao_dois ;;
        3) opcao_tres ;;
        4) opcao_quatro ;;
        5) opcao_cinco ;;
        6) opcao_seis ;;
        7) opcao_sete ;;
        8) opcao_oito ;;
        9) opcao_nove ;;
        0) echo "Saindo..."
           # Calcula a hash SHA1 do arquivo history.log.enc antes de sair
           
           sair ;;
           exit ;;
        *) echo "Opção inválida!"; sleep 1 ;;
    esac
}

# Funções para cada opção do menu
opcao_um() {
    clear
    echo -e "Tentativas de Login Falhas por IP\n"
    # cat auth2.log | grep "Failed password" | cut -d " " -f1,2,3,4
    cat auth2.log | grep "Failed password" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | uniq -c | sort -r
    echo ""
    read -p "Pressione enter para continuar..."
}

opcao_dois() {
    clear
    echo -e "Tentativas de Login Falhas por IP +  Datas\n"
    cat auth2.log | grep "Failed password" | cut -d " " -f1,2,3,4 | head -n 1
    echo "--->   Primeira Data/Hora"
    cat auth2.log | grep "Failed password" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | uniq -c | sort -r
    echo "--->   Ultima Data/Hora"
    cat auth2.log | grep "Failed password" | cut -d " " -f1,2,3,4 | tail -n 1
    echo ""
    read -p "Pressione enter para continuar..."
}

opcao_tres() {
    clear
    echo "Filtragem pelo Número de Tentativas Falhadas"
    echo ""
    echo -n "Digite o valor mínimo para filtrar o arquivo: "
    read valor_minimo
    cat auth2.log | grep "Failed password" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | uniq -c | sort -r | awk -v min="$valor_minimo" '$1 >= min'
    echo ""
    read -p "Pressione enter para continuar..."
}

opcao_quatro() {
    clear
    echo "Filtrar a Pesquisa por um Intervalo Temporal"
    echo ""

    # Pergunta ao usuário por qual mês ele quer pesquisar
    echo "Digite o mês para pesquisa (ex: Feb):"
    read mes

    # Pergunta ao usuário por qual dia ele quer pesquisar
    echo "Digite o dia para pesquisa (ex: 5):"
    read dia

    # Usa cat para ler o arquivo e grep para filtrar pelo mês e dia
    cat auth2.log | grep "$mes $dia"

    read -p "Pressione enter para continuar..."
}

opcao_cinco() {
    clear
    echo "Cifra Histórico"
    echo ""

    # Define o arquivo de saída onde o histórico cifrado será salvo
    arquivo_saida="history.log.enc"

    # Senha para a cifração
    senha="MESI"

    # Captura a saída do comando 'history', cifra e salva no arquivo de saída
    history | openssl enc -aes-256-cbc -salt -pass pass:"$senha" -out "$arquivo_saida"

    echo "O histórico foi cifrado e salvo como $arquivo_saida"
    echo ""
    read -p "Pressione enter para continuar..."
}

opcao_seis() {
    echo "Você escolheu a Opção 6"
    # Adicione aqui o código que deseja executar para a opção 6
    read -p "Pressione enter para continuar..."
}

opcao_sete() {
    echo "Você escolheu a Opção 7"
    # Adicione aqui o código que deseja executar para a opção 7
    read -p "Pressione enter para continuar..."
}

opcao_oito() {
    echo "Você escolheu a Opção 8"
    # Adicione aqui o código que deseja executar para a opção 8
    read -p "Pressione enter para continuar..."
}

opcao_nove() {
    echo "Você escolheu a Opção 9"
    # Adicione aqui o código que deseja executar para a opção 9
    read -p "Pressione enter para continuar..."
}

# Função para calcular a hash SHA1 de um arquivo
Hashing() {
    local arquivo=$1 # Armazena o argumento (caminho do arquivo) em uma variável local

    # Verifica se o arquivo existe
    if [ ! -f "$arquivo" ]; then
        echo "Arquivo não encontrado: $arquivo"
        return 1 # Sai da função com erro
    fi

    # Calcula e exibe a hash SHA1 do arquivo
    sha1sum "$arquivo"
}


# Loop principal do menu
while true; do
    exibir_menu
    processar_escolha
done
