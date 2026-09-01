# ================================
# STAGE 1: Compilação (Builder)
# ================================
FROM dhdiegoribeiro/tfls-build-environment:latest AS builder

WORKDIR /app

COPY files/realotsloginserver-master/ /app/
COPY docker/login/patches /tmp/patches/

# Aplicação dos patches
RUN patch /app/src/connection.cpp < /tmp/patches/connection.patch \
 && patch /app/src/database.cpp   < /tmp/patches/database.patch \
 && patch /app/src/tools.cpp      < /tmp/patches/tools.patch \
 && patch /app/config.lua         < /tmp/patches/config.patch

# Criação do diretório de build
RUN mkdir -p /app/build

# Configuração e Compilação (devem ficar no mesmo WORKDIR ou encadeadas)
WORKDIR /app/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. \
 && make -j$(nproc)

# ================================
# STAGE 2: Execução (Runtime)
# ================================
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Apenas dependências de execução (sem ferramentas de build)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmysqlclient21 \
    liblua5.2-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia apenas os arquivos necessários da etapa anterior
COPY --from=builder /app/build/tfls /app/tfls
COPY --from=builder /app/config.lua /app/config.lua
COPY --from=builder /app/gameservers.xml /app/gameservers.xml

EXPOSE 7171

CMD ["./tfls"]