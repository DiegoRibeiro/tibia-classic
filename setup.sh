#!/bin/bash
set -e
set -o pipefail

GAME_FILES="files/tibia-game.tarball.tar.gz"
QUERYMANAGER_FILES="files/querymanager.zip"
LOGIN_FILES="files/realotsloginserver-master.zip"
GAMEBIN_FILES="files/game"
DENNISLIB_FILES="files/dennis-libraries.rar"

BACKUP_TGZ="game-zanera.tgz"
DEST_DIR="data"

EXACT_MAP_SECTORS=9873

check_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "ERRO: $file não encontrado."
        exit 1
    fi
}

check_command() {
    local command="$1"

    if ! command -v "$command" >/dev/null 2>&1; then
        echo "ERRO: O comando '$command' não está instalado."
        
        # Mapeia apenas os comandos que você autorizar a exibição da instrução
        case "$command" in
            pv)
                echo " -> Sugestão de instalação: sudo apt update && sudo apt install -y pv"
                ;;
            unzip)
                echo " -> Sugestão de instalação: sudo apt update && sudo apt install -y unzip"
                ;;
            unrar)
                echo " -> Sugestão de instalação: sudo apt update && sudo apt install -y unrar"
                ;;
            # Comandos do coreutils/sistema não exibem instrução para evitar pacotes indesejados
            *)
                echo " -> Este é um utilitário do sistema. Verifique o seu ambiente Linux/WSL."
                ;;
        esac

        echo ""
        exit 1
    fi
}

is_dir_not_empty() {
    local dir="$1"
    [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]
}

count_files_exact() {
    local dir="$1"
    local expected_count="$2"
    local ext="${3:-*}"

    if [ ! -d "$dir" ]; then
        return 1
    fi

    local count
    count=$(find "$dir" -maxdepth 1 -type f -name "$ext" 2>/dev/null | wc -l)

    [ "$count" -eq "$expected_count" ]
}

# Extrai arquivos tar.gz exibindo barra de progresso se o 'pv' existir
extract_tgz_smart() {
    local archive="$1"
    local target_dir="$2"

    if command -v pv >/dev/null 2>&1; then
        pv "$archive" | tar -xzf - -C "$target_dir"
    else
        tar -xzf "$archive" -C "$target_dir"
    fi
}

# Extrai .zip exibindo [OK] ou a mensagem de erro original do unzip na mesma linha
extract_zip_smart() {
    local archive="$1"
    local target_dir="$2"
    local label="$3"

    [ -n "$label" ] && echo -n "Extraindo $label... "

    mkdir -p "$target_dir"

    # Captura a saída de erro do unzip
    local err_msg
    err_msg=$(unzip -q -o "$archive" -d "$target_dir" 2>&1)
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "[OK]"
    else
        # Remove quebras de linha para manter o erro na mesma linha
        local clean_err
        clean_err=$(echo "$err_msg" | tr '\n' ' ' | xargs)
        echo "[ERRO: $clean_err]"
        return $exit_code
    fi
}

# Extrai .rar exibindo [OK] ou a mensagem de erro original do unrar na mesma linha
extract_rar_smart() {
    local archive="$1"
    local target_dir="$2"
    local label="$3"

    [ -n "$label" ] && echo -n "Extraindo $label... "

    mkdir -p "$target_dir"

    local err_msg
    err_msg=$(unrar x -inul -y "$archive" "$target_dir" 2>&1)
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "[OK]"
    else
        local clean_err
        clean_err=$(echo "$err_msg" | tr '\n' ' ' | xargs)
        echo "[ERRO: $clean_err]"
        return $exit_code
    fi
}

copy_dir_with_progress() {
    local source_dir="$1"
    local dest_dir="$2"

    if command -v pv >/dev/null 2>&1; then
        local size

        size=$(
            find "$source_dir" -type f -printf '%s\n' |
            awk '{ total += 512 + (int(($1 + 511) / 512) * 512) }
                 END { print total + 1024 }'
        )

        tar -cf - \
            -C "$(dirname "$source_dir")" \
            "$(basename "$source_dir")" \
            | pv -s "$size" -p -t -e -r \
            | tar -xf - -C "$dest_dir"
    else
        cp -r "$source_dir" "$dest_dir/"
    fi
}

# ==========================================
# 1. VERIFICAÇÃO DE DEPENDÊNCIAS DO SISTEMA
# ==========================================
echo "Verificando dependências..."
check_command unzip
check_command tar
check_command unrar

# Informa sobre o pv de forma puramente informativa
if ! command -v pv >/dev/null 2>&1; then
    echo " (Dica opcional: instale 'pv' com 'sudo apt install pv' para ver barra de progresso nas extrações)"
fi

# ==========================================
# 2. VERIFICAÇÃO DOS ARQUIVOS FONTE (files/)
# ==========================================
echo "Verificando arquivos necessários..."
check_file "$GAME_FILES"
check_file "$QUERYMANAGER_FILES"
check_file "$LOGIN_FILES"
check_file "$GAMEBIN_FILES"
check_file "$DENNISLIB_FILES"

echo "Todos os arquivos necessários foram encontrados!"

# ==========================================
# 3. EXTRAÇÃO DOS PACOTES NECESSARIOS
# ==========================================
if [ ! -f "files/querymanager/querymanager" ]; then
    #unzip "$QUERYMANAGER_FILES" -d files/
    extract_zip_smart "$QUERYMANAGER_FILES" "files/" "QueryManager"
else
    echo "QueryManager já está extraído."
fi

if [ ! -f "files/realotsloginserver-master/CMakeLists.txt" ]; then
    #unzip "$LOGIN_FILES" -d files/
    extract_zip_smart "$LOGIN_FILES" "files/" "Login Server"
else
    echo "Login Server já está extraído."
fi

if [ ! -f "files/dennis-libraries/libc.so.6" ]; then
    #unrar x "$DENNISLIB_FILES" files/
    extract_rar_smart "$DENNISLIB_FILES" "files/" "Dennis Libraries"
else
    echo "Dennis Libraries já está extraído."
fi

if [ ! -f "files/tibiagame/ip-address.txt" ]; then
    echo "Extraindo Tibia Game..."
    mkdir -p files/tibiagame
    #tar -xzvf "$GAME_FILES" -C files/tibiagame/
    extract_tgz_smart "$GAME_FILES" "files/tibiagame/"
else
    echo "Tibia Game já está extraído."
fi

# ==========================================
# 4. GERENCIAMENTO DE DADOS DO HOST (data/)
# ==========================================

if ! count_files_exact "$DEST_DIR/map" "$EXACT_MAP_SECTORS" "*.sec" || ! is_dir_not_empty "$DEST_DIR/usr" || [ ! -f "$DEST_DIR/dat/owners.dat" ]; then
    echo ""
    echo "=================================================================="
    echo " Setup pendente: Dados em '$DEST_DIR/' faltam ou estão incompletos!"
    echo " (Exige: EXATAMENTE $EXACT_MAP_SECTORS setores .sec, pasta 'usr' e 'owners.dat')"
    echo "=================================================================="
    
    mkdir -p "$DEST_DIR"
    USOU_BACKUP=false

    # Pergunta sobre restauração de backup se o arquivo existir
    if [ -f "$BACKUP_TGZ" ]; then
        read -p "Arquivo de backup ($BACKUP_TGZ) encontrado. Deseja restaurá-lo em '$DEST_DIR/'? [S/n]: " RESP
        case "$RESP" in
            [nN][oO]|[nN])
                USOU_BACKUP=false
                ;;
            *)
                echo "Restaurando backup em '$DEST_DIR/'..."
                #tar -xzvf "$BACKUP_TGZ" -C "$DEST_DIR/"
                extract_tgz_smart "$BACKUP_TGZ" "$DEST_DIR/"
                USOU_BACKUP=true
                ;;
        esac
    fi

    # Fallback: Se não usou backup, copia a base original exigindo validação estrita
    if [ "$USOU_BACKUP" = false ]; then
        echo "Validando integridade dos dados de origem em files/tibiagame/..."
        
        if ! count_files_exact "files/tibiagame/map" "$EXACT_MAP_SECTORS" "*.sec"; then
            ACTUAL_COUNT=$(find "files/tibiagame/map" -maxdepth 1 -type f -name "*.sec" 2>/dev/null | wc -l)
            echo "ERRO CRÍTICO: O mapa fonte possui $ACTUAL_COUNT setores, mas requer exatamente $EXACT_MAP_SECTORS!"
            exit 1
        fi

        if ! is_dir_not_empty "files/tibiagame/usr"; then
            echo "ERRO CRÍTICO: A pasta 'files/tibiagame/usr' está vazia ou ausente!"
            exit 1
        fi

        if [ ! -f "files/tibiagame/dat/owners.dat" ]; then
            echo "ERRO CRÍTICO: Arquivo 'files/tibiagame/dat/owners.dat' não foi encontrado!"
            exit 1
        fi

        echo "Copiando dados originais (mapa, players e casas) para '$DEST_DIR/'..."
        
        mkdir -p "$DEST_DIR/dat"

        copy_dir_with_progress "files/tibiagame/map" "$DEST_DIR"
        copy_dir_with_progress "files/tibiagame/usr" "$DEST_DIR"
        cp files/tibiagame/dat/owners.dat "$DEST_DIR/dat/"

        echo "Dados originais copiados com sucesso!"
    fi

    # Validação Final pós-extração/cópia
    if [ ! -f "$DEST_DIR/dat/owners.dat" ]; then
        echo "ERRO CRÍTICO: O arquivo '$DEST_DIR/dat/owners.dat' não foi gerado no destino."
        exit 1
    fi

    if ! is_dir_not_empty "$DEST_DIR/usr"; then
        echo "ERRO CRÍTICO: A pasta '$DEST_DIR/usr' não foi populada corretamente."
        exit 1
    fi

    if ! count_files_exact "$DEST_DIR/map" "$EXACT_MAP_SECTORS" "*.sec"; then
        echo "ERRO CRÍTICO: O diretório '$DEST_DIR/map' foi populado de forma incompleta."
        exit 1
    fi
else
    echo "Mapa e dados em '$DEST_DIR/' validados com sucesso (EXATAMENTE $EXACT_MAP_SECTORS setores .sec e arquivos essenciais presentes)."
fi

# ==========================================
# 5. CONSTRUÇÃO DAS IMAGENS DOCKER
# ==========================================
echo "Construindo as imagens Docker..."
docker compose build

echo
echo "======================================"
echo "Setup concluído com sucesso!"
echo "======================================"

touch .setup_complete