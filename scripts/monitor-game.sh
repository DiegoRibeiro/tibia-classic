#!/bin/bash

set -e

log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*"
}

log "Container iniciado"
log "PID do wrapper: $$"

log "Removendo game.pid antigo"
rm -f /game/save/game.pid

log "Iniciando game daemon"
/game/bin/game daemon

log "game daemon retornou com código $?"
log "game.pid: $(cat /game/save/game.pid 2>/dev/null || echo 'não existe')"

shutdown() {
    if [ -f /game/save/game.pid ]; then
        GAME_PID=$(cat /game/save/game.pid)
        log "Enviando SIGTERM para o game (PID: $GAME_PID)..."
        
        # Envia SIGTERM diretamente para o PID do jogo
        kill -15 "$GAME_PID" 2>/dev/null || true

        log "Aguardando término do game (SaveMap/CloseGame)..."
        # Aguarda enquanto o processo do game ainda estiver ativo
        while kill -0 "$GAME_PID" 2>/dev/null; do
            sleep 1
        done
        
        log "Game finalizado com sucesso."
    else
        log "Arquivo /game/save/game.pid não encontrado."
    fi

    exit 0
}

trap shutdown SIGTERM SIGINT

log "Iniciando processo de espera"

#tail -f /dev/null &
sleep infinity &
WAIT_PID=$!

log "Processo de espera: PID $WAIT_PID"
log "Wrapper aguardando..."

wait "$WAIT_PID"