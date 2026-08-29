#!/bin/bash
set -e

docker compose cp tibiagame:/game/game-zanera.tgz ./

echo
echo "======================================"
echo "Backup concluído com sucesso!"
echo "======================================"