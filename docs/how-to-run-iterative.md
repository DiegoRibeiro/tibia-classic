
docker compose run --rm --service-ports tibiagame bash
/game/bin/game daemon

para ver o log
/game/bin/pl

entrar no container
docker compose exec -it tibiagame bash

checar o processo
ps -ef