#!/bin/bash
set -e

BACKUP_FILE="${1:-game-zanera.tgz}"

# 1. Valida se o arquivo de backup existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERRO: Arquivo '$BACKUP_FILE' não encontrado."
    echo "Uso: $0 <arquivo_de_backup.tgz>"
    exit 1
fi

# 2. Verifica se o container do jogo está em execução
if docker compose ps --status running tibiagame | grep -q "tibiagame"; then
    echo "ERRO: O servidor (tibiagame) está RODANDO!"
    echo "Execute o ./stop.sh primeiro para evitar corrupção de saves durante a restauração."
    exit 1
fi

echo "Restaurando backup no volume via Compose..."
docker compose run --rm --no-deps \
  -v "$(pwd)/$BACKUP_FILE:/tmp/backup.tgz" \
  --entrypoint "tar -xzvf /tmp/backup.tgz -C /game/" \
  tibiagame

echo
echo "======================================"
echo "Restauração concluída via Compose!"
echo "======================================"