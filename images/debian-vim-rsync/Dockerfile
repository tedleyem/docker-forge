FROM debian:trixie-slim

# Igore pinning package versions with hadolint
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    rsync \
    vim \
    tmux \
    iputils-ping \
    netcat-openbsd \
    dnsutils \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]