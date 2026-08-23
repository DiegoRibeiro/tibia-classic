FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    g++ \
    patch \
    libmysqlclient-dev \
    mysql-server \
    make \
    iputils-ping \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY files/querymanager/ /app/
COPY patches/main.patch /tmp/main.patch

RUN patch /app/main.cpp < /tmp/main.patch

RUN make

CMD ["./querymanager"]