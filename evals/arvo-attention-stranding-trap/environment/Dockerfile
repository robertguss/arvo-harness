FROM ubuntu:24.04

# Runtime base for Arvo Mix release (ERTS + NIFs). Agent uploads release tarball.
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libtinfo6 \
        zlib1g \
        libstdc++6 \
        libgcc-s1 \
        python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Task workspace (agent mutates sensor_hub.ex)
COPY workspace/ /app/

# Isolated HOME for Arvo sessions / audit trail
RUN mkdir -p /home/agent/.arvo/sessions \
    && chmod -R 777 /home/agent
ENV HOME=/home/agent

WORKDIR /app
