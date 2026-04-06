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
    redis-server \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install specific Jinja2 version early to prevent dependency conflicts later
RUN pip3 install Jinja2==3.0.0

# Clone repositories
RUN git clone https://github.com/mushorg/tanner.git && \
    git clone https://github.com/mushorg/phpox.git tanner/phpox.git

RUN cd tanner/phpox.git && \
    make && \
    pip3 install -r requirements.txt

# Setup tanner
RUN cd tanner && \
    pip3 install -r requirements.txt && \
    pip3 install aiohttp==3.7.4.post0 && \
    python3 setup.py install && \
    mkdir -p web/static

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
