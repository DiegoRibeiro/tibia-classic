# Game Server Save / Reboot

Durante o `Server Save`, o servidor antigo não é simplesmente reiniciado.

O comportamento observado foi:

```text
game daemon (PID 10)
        │
        └── processos filhos
              ↓
        Server Save
              ↓
        game.pid desaparece
              ↓
        game termina
              ↓
        reboot-daily daemon
              ↓
        backup (tar/gzip)
              ↓
        /game/bin/game daemon
              ↓
        novo game.pid
              ↓
        novo processo game daemon
```

Exemplo observado:

```text
Antes:
game.pid = 10
PID 10 = /game/bin/game daemon

Durante o save:
game.pid = não existe
PID 10 = /bin/bash /game/bin/reboot-daily daemon

Backup:
PID 8734 = tar

Depois:
game.pid = 8894
PID 8894 = /game/bin/game daemon
```

O `game.pid` desapareceu por aproximadamente 27 segundos durante o backup antes de ser recriado.

**Conclusão:** o `reboot-daily` permanece executando durante o Server Save e é responsável por iniciar um novo `game daemon` após o backup. No Docker, algum processo persistente precisa manter o container vivo durante essa transição.
