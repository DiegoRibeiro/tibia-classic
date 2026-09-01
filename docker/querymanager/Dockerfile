# ================================
# STAGE 1: Compilação (Builder)
# ================================
FROM dhdiegoribeiro/qm-build-environment:latest AS builder

WORKDIR /app

COPY files/querymanager/ /app/
COPY docker/querymanager/patches/main.patch /tmp/main.patch

RUN patch /app/main.cpp < /tmp/main.patch
RUN make

# ================================
# STAGE 2: Execução (Runner)
# ================================
FROM ubuntu:22.04 AS runner

ENV DEBIAN_FRONTEND=noninteractive

# Instala apenas as bibliotecas dinâmicas necessárias em runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmysqlclient21 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia apenas o executável gerado no estágio builder
COPY --from=builder /app/querymanager /app/querymanager

CMD ["./querymanager"]