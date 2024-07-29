# Encerra o programa caso não tenha sido executado como root.
function verificar_root {
    echo 'Conferindo se foi executado como root...'
    if [ "$EUID" -ne 0 ]; then
        echo "Este script precisa ser executado como root."
        exit 1
    fi
}

function verificar_tem_argumentos {
    if [ $# -ne 0 ]; then
        show_help
    fi
}

# Função para exibir mensagens de erro e sair
function exibir_erro {
    echo "$(colorir "vermelho" "Erro"): $1"
    exit 1
}

# Função para executar comandos e lidar com erros
function run {
    if [[ $DRY ]]; then
        echo "Simulando comando: $*"
    else
        "$@" || exibir_erro "Falha ao executar o comando: $*"
    fi
}

# Colorir as mensagens, deve ser usado com subshell
function colorir {
    declare -A cores
    local cores=(
        [preto]="0;30"
        [vermelho]="0;31"
        [verde]="0;32"
        [amarelo]="0;33"
        [azul]="0;34"
        [magenta]="0;35"
        [ciano]="0;36"
        [branco]="0;37"
        [preto_claro]="1;30"
        [vermelho_claro]="1;31"
        [verde_claro]="1;32"
        [amarelo_claro]="1;33"
        [azul_claro]="1;34"
        [magenta_claro]="1;35"
        [ciano_claro]="1;36"
        [branco_claro]="1;37"
        [laranja]="38;5;208"
        [rosa]="38;5;206"
        [azul_celeste]="38;5;45"
        [verde_lima]="38;5;118"
    )

    local cor=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local texto=$2
    local string='${cores['"\"$cor\""']}'
    eval "local cor_ansi=$string"
    local cor_reset="\e[0m"

    if [[ -z "$cor_ansi" ]]; then
        cor_ansi=${cores["branco"]}  # Cor padrão, caso a cor seja inválida
    fi

    # Imprimir o texto com a cor selecionada
    echo -e "\e[${cor_ansi}m${texto}${cor_reset}"
}

# Salvar os arquivos atuais
function backup_old_files () {
    echo "# $(colorir "ciano" "Backup gerado em ./files")"
    run cp -v $OLD_PAGE_TRUNKS $REMOTE_FILES/page.trunks.php.$(date +'%d-%m-%Y-%H-%M-%S').bkp
    run cp -v $OLD_PAGE_ROUTING $REMOTE_FILES/page.routing.php.$(date +'%d-%m-%Y-%H-%M-%S').bkp
}

# Substituir os arquivos atuais pelos novos
function replace_old_files () {
    echo "# $(colorir "ciano" "Substituindo os arquivos")"
    run rm -rfv $OLD_PAGE_TRUNKS
    run rm -rfv $OLD_PAGE_ROUTING
    run cp -v $NEW_PAGE_TRUNKS $OLD_PAGE_TRUNKS
    run cp -v $NEW_PAGE_ROUTING $OLD_PAGE_ROUTING
}

function show_help {
    echo "Usage: sudo ${BASH_SOURCE[0]}"
    exit 1
}

# Inicializa variáveis
CURRDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REMOTE_FILES="$CURRDIR/files"
EDIT_PATH="/var/www/html/admin/modules/core"

OLD_PAGE_TRUNKS="$EDIT_PATH/page.trunks.php"
OLD_PAGE_ROUTING="$EDIT_PATH/page.routing.php"
NEW_PAGE_TRUNKS="$REMOTE_FILES/page.trunks.php"
NEW_PAGE_ROUTING="$REMOTE_FILES/page.routing.php"

# // RUNTIME

echo "$(colorir "azul" "Inicializando")..."
echo "RUNNING DIRECTORY: $CURRDIR"
verificar_tem_argumentos
verificar_root

backup_old_files
replace_old_files

echo "# $(colorir "ciano" "Caso a pagina de editar troncos bugue, reverta para os arquivos que foram salvos em ./files")"

echo "$(colorir "verde" "Finalizado")"
