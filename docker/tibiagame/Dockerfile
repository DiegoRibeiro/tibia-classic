FROM ubuntu:22.04

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        patch \
        libc6:i386 \
        libstdc++6:i386 \
        libgcc-s1:i386 \
        zlib1g:i386 \
        libstdc++5:i386 \
        iputils-ping \
    && rm -rf /var/lib/apt/lists/*

COPY files/tibiagame /game
COPY files/dennis-libraries /tmp/dennis-libraries
COPY files/game /tmp/game
COPY patches/tibia.patch /tmp/tibia.patch

RUN rm -f /game/save/game.pid

RUN mv /game/bin/game /game/bin/game.bkp && \
    cp /tmp/game /game/bin/ && \
    cp /tmp/dennis-libraries/*.so* /lib/ && \
    cp /tmp/dennis-libraries/*.so* /lib32/ && \
    cp /game/.tibia /root && \
    chmod -R 777 /lib && \
    chmod +x /game/bin/game

RUN patch /root/.tibia < /tmp/tibia.patch

WORKDIR /

#CMD ["/game/bin/game"]
CMD ["sh", "-c", "rm -f /game/save/game.pid && exec /game/bin/game"]