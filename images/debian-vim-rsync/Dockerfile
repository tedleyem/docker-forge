FROM debian:trixie-slim 

RUN apt update && apt-get install -y --no-install-recommends \
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
