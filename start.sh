#!/bin/bash
set -e

# Valida se o setup foi concluído
if [ ! -f ".setup_complete" ]; then
    echo "ERRO: O setup ainda não foi executado!"
    echo "Por favor, rode o script ./setup.sh antes de iniciar o servidor."
    exit 1
fi

wait_for_port() {
    local service="$1"
    local port="$2"

    echo "Esperando $service na porta $port..."

    until docker compose exec -T "$service" nc -z localhost "$port" 2>/dev/null; do
        sleep 1
    done

    echo "$service OK!"
}

echo "Subindo banco..."
docker compose up -d --no-build database

echo "Aguardando MySQL..."

until docker compose exec -T database mysqladmin ping \
    -h localhost \
    -u root \
    -proot \
    --silent; do
    sleep 2
done

echo "Banco pronto!"

docker compose up -d --no-build querymanager
echo "Aguardando QueryManager..."
wait_for_port querymanager 17778

docker compose up -d --no-build login
echo "Aguardando Login..."
wait_for_port login 7171

docker compose up -d --no-build tibiagame

echo "Tibia Classic iniciado!"
