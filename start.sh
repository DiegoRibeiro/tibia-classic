#!/bin/bash
set -e

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
docker compose up -d database

echo "Aguardando MySQL..."

until docker compose exec -T database mysqladmin ping \
    -h localhost \
    -u root \
    -proot \
    --silent; do
    sleep 2
done

echo "Banco pronto!"

docker compose up -d querymanager
echo "Aguardando QueryManager..."
wait_for_port querymanager 17778

docker compose up -d login
echo "Aguardando Login..."
wait_for_port login 7171

docker compose up -d tibiagame

echo "Tibia Classic iniciado!"
