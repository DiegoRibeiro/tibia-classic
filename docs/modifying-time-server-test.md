# Teste de alteração de horário no WSL

## Objetivo

Alterar temporariamente o relógio do WSL para testar o `reboot-daily` e o `server save` do Tibia.

Isso é necessário porque o servidor utiliza o horário do sistema para determinar quando executar determinadas rotinas.

## Ambiente

* Windows
* WSL2
* Ubuntu 24.04 (Noble)
* systemd habilitado
* Docker rodando dentro do WSL

## Problema encontrado

Alterar o horário do Windows não altera imediatamente o horário utilizado pelo WSL.

Além disso, o WSL possui mecanismos de sincronização de horário que podem restaurar o relógio automaticamente.

O `/proc/cmdline` inicialmente apresentava:

```text
hv_utils.timesync_implicit=1
...
hv_utils.timesync_implicit=0
```

## Procedimento que funcionou

Primeiro, parar o `systemd-timesyncd`:

```bash
sudo systemctl stop systemd-timesyncd
```

Verificar:

```bash
systemctl status systemd-timesyncd
```

O serviço deve aparecer como:

```text
Active: inactive (dead)
```

Depois, alterar manualmente o horário:

```bash
sudo date -s "2026-08-29 05:59:50"
```

Verificar:

```bash
date
```

### Resultado

Com o `systemd-timesyncd` parado, o horário permaneceu alterado e continuou avançando normalmente:

```text
Sat Aug 29 05:59:50 -03 2026
Sat Aug 29 05:59:55 -03 2026
Sat Aug 29 05:59:57 -03 2026
Sat Aug 29 05:59:58 -03 2026
```

Também foi necessário remover/desabilitar o mecanismo `hv_utils.timesync_implicit` que estava fazendo a sincronização implícita do horário no WSL.

## Importante

Não assumir que simplesmente executar:

```bash
sudo date -s ...
```

será suficiente.

Se algum mecanismo de sincronização estiver ativo, o horário pode ser restaurado imediatamente.

## Para repetir o teste

1. Verificar o horário:

```bash
date
```

2. Verificar o `systemd-timesyncd`:

```bash
systemctl status systemd-timesyncd
```

3. Parar o serviço:

```bash
sudo systemctl stop systemd-timesyncd
```

4. Ajustar o horário:

```bash
sudo date -s "YYYY-MM-DD HH:MM:SS"
```

5. Confirmar:

```bash
date
```

6. Executar o teste do servidor.

## Observação

Este procedimento é apenas para testes.

Ainda não foi definida uma solução permanente para manipulação do horário do ambiente de desenvolvimento.
