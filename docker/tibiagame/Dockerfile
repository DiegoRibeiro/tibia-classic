FROM ubuntu:22.04

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y patch && \
    apt-get install -y libc6:i386 && \
    apt-get install -y libstdc++5:i386 && \
    rm -rf /var/lib/apt/lists/*

COPY files/tibia-game.tarball.tar.gz /tmp/tibia-game.tarball.tar.gz
COPY files/dennis-libraries /tmp/dennis-libraries
COPY files/game /tmp/game
COPY docker/tibiagame/patches /tmp/patches
COPY docker/tibiagame/script/entrypoint.sh /entrypoint.sh

RUN mkdir -p /game && \
    tar -xzf /tmp/tibia-game.tarball.tar.gz -C /game/ && \
    rm /tmp/tibia-game.tarball.tar.gz

RUN mv /game/bin/game /game/bin/game.bkp && \
    cp /tmp/game /game/bin/ && \
    cp /tmp/dennis-libraries/*.so* /lib/ && \
    chmod +x /lib/*.so* && \
    cp /game/.tibia /root && \
    chmod +x /game/bin/game && \
    patch /root/.tibia < /tmp/patches/tibia.patch && \
    patch /game/bin/reboot-daily < /tmp/patches/reboot-daily.patch && \
    rm -rf /tmp/dennis-libraries /tmp/game /tmp/patches

WORKDIR /

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]