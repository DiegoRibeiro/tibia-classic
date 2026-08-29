#!/bin/bash
set -e

GAME_FILES="files/tibia-game.tarball.tar.gz"
QUERYMANAGER_FILES="files/querymanager.zip"
LOGIN_FILES="files/realotsloginserver-master.zip"
GAMEBIN_FILES="files/game"
DENNISLIB_FILES="files/dennis-libraries.rar"

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
        echo "ERRO: comando '$command' não encontrado."
        exit 1
    fi
}

echo "Verificando dependências..."
check_command unzip
check_command tar
check_command unrar

echo "Verificando arquivos necessários..."

check_file "$GAME_FILES"
check_file "$QUERYMANAGER_FILES"
check_file "$LOGIN_FILES"
check_file "$GAMEBIN_FILES"
check_file "$DENNISLIB_FILES"

echo "Todos os arquivos necessários foram encontrados!"

if [ ! -f "files/querymanager/querymanager" ]; then
    echo "Extraindo QueryManager..."
    unzip "$QUERYMANAGER_FILES" -d files/
else
    echo "QueryManager já está extraído."
fi

if [ ! -f "files/realotsloginserver-master/CMakeLists.txt" ]; then
    echo "Extraindo Login Server..."
    unzip "$LOGIN_FILES" -d files/
else
    echo "Login Server já está extraído."
fi

if [ ! -f "files/dennis-libraries/libc.so.6" ]; then
    echo "Extraindo Dennis Libraries..."
    unrar x "$DENNISLIB_FILES" files/
else
    echo "Dennis Libraries já está extraído."
fi

if [ ! -f "files/tibiagame/ip-address.txt" ]; then
    echo "Extraindo Tibia Game..."
    mkdir -p files/tibiagame
    tar -xzvf "$GAME_FILES" -C files/tibiagame/
else
    echo "Tibia Game já está extraído."
fi

echo "Construindo as imagens Docker..."
docker compose build

echo
echo "======================================"
echo "Setup concluído com sucesso!"
echo "======================================"

touch .setup_complete