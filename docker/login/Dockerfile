FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    patch \
    liblua5.2-dev \
    libgmp3-dev \
    libmysqlclient-dev \
    libboost-system-dev \
    libpugixml-dev \
    iputils-ping \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY files/realotsloginserver-master/ /app/
COPY patches/connection.patch /tmp/connection.patch
COPY patches/database.patch /tmp/database.patch
COPY patches/config.patch /tmp/config.patch

RUN patch /app/src/connection.cpp < /tmp/connection.patch \
    && patch /app/src/database.cpp < /tmp/database.patch \
    && patch /app/config.lua < /tmp/config.patch

RUN mkdir build \
    && cd build \
    && cmake .. \
    && make

RUN cp config.lua build/ \
    && cp gameservers.xml build/

WORKDIR /app/build

EXPOSE 7171

CMD ["./tfls"]