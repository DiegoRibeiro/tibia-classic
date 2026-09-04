FROM dhdiegoribeiro/tg-runtime-environment:latest

COPY files/tibiagame /game
RUN mkdir -p /game/log
COPY files/tibiagame/.tibia /root
COPY files/dennis-libraries /tmp/dennis-libraries
COPY files/game /tmp/game
COPY docker/tibiagame/patches /tmp/patches
COPY docker/tibiagame/script/entrypoint.sh /entrypoint.sh


RUN mv /game/bin/game /game/bin/game.bkp && \
    cp /tmp/game /game/bin/ && \
    cp /tmp/dennis-libraries/*.so* /lib/ && \
    chmod +x /lib/*.so* && \
    chmod +x /game/bin/game && \
    patch /root/.tibia < /tmp/patches/tibia.patch && \
    patch /game/bin/reboot-daily < /tmp/patches/reboot-daily.patch && \
    rm -rf /tmp/dennis-libraries /tmp/game /tmp/patches

WORKDIR /

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]