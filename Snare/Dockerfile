FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /opt

# System dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-dev \
    python3-pip \
    vim \
    git \
    net-tools \
    iputils-ping \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Clone repository
RUN git clone https://github.com/mushorg/snare.git

# Setup snare
RUN cd snare && \
    pip3 install -r requirements.txt && \
    python3 setup.py install

# Install specific Jinja2 version to prevent conflicts
RUN pip3 install Jinja2==3.0.0

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
