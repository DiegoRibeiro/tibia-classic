# Binary Debugging

Guia rápido para investigar o comportamento de binários legados dentro do container.

## 1. Entrar no container

```bash
docker compose exec -it tibiagame bash
```

## 2. Ver processos

```bash
ps -ef
```

Para acompanhar um processo específico:

```bash
ps -fp <PID>
```

## 3. Descobrir o PID do servidor

```bash
cat /game/save/game.pid
```

## 4. Inspecionar strings do binário

Instalar:

```bash
apt-get update
apt-get install -y binutils
```

Pesquisar termos:

```bash
strings /game/bin/game | grep -iE 'shutdown|terminate|stop|quit|signal|control|shm'
```

## 5. Investigar sinais e IPC

Instalar:

```bash
apt-get install -y strace util-linux
apt install -y iproute2
apt install -y vim-common
```

Ver IPC:

```bash
ipcs -a
```

Ver shared memory:

```bash
ls -la /dev/shm
```

## 6. Anexar o strace ao processo

```bash
strace -f -e trace=signal,ipc,process -p <PID>
```

Exemplo:

```bash
strace -f -e trace=signal,ipc,process -p $(cat /game/save/game.pid)
```

## 7. Observar arquivos e processos durante um evento

Antes do teste:

```bash
cat /game/save/game.pid
ps -ef
ipcs -a
ls -la /dev/shm
```

Executar o evento que deseja investigar.

Depois:

```bash
cat /game/save/game.pid
ps -ef
ipcs -a
ls -la /dev/shm
```

### Objetivo

Comparar o estado antes e depois para descobrir:

* mudança de PID;
* criação ou remoção de `game.pid`;
* processos filhos;
* sinais enviados;
* uso de shared memory;
* processos auxiliares;
* mecanismos de shutdown/restart.
