FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install needed packages
RUN apt-get update && apt-get install -y \
    git cmake make g++ autoconf libtool pkg-config \
    libdumbnet-dev libhwloc-dev libluajit-5.1-dev \
    libssl-dev libpcap-dev libpcre2-dev zlib1g-dev liblzma-dev \
    flex uuid wget curl net-tools\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /snorty

# -------------------------
# Build libdaq (latest)
# -------------------------
RUN git clone https://github.com/snort3/libdaq.git && \
    cd libdaq && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) || make -j1 && \
    make install && \
    ldconfig

# -------------------------
# Build libml
# -------------------------
RUN git clone https://github.com/snort3/libml.git && \
    cd libml && \
    ./configure.sh && \
    cd build && \
    make -j$(nproc) || make -j1 && \
    make install && \
    ldconfig

# -------------------------
# Build Snort3
# -------------------------
# I'm using --prefix=/usr/local to keep the configuration files in /usr/local/etc/snort
# This avoids breaking the existing compose.yaml volumes and entrypoint.sh paths.
RUN git clone https://github.com/snort3/snort3.git && \
    cd snort3 && \
    ./configure_cmake.sh --prefix=/usr/local --enable-debug-msgs && \
    cd build && \
    make -j$(nproc) || make -j1 && \
    make install && \
    ln -s /usr/local/bin/snort /usr/sbin/snort && \
    ldconfig

# -------------------------
# Project specific adjustments
# -------------------------
RUN mkdir -p /usr/local/etc/rules /usr/local/etc/so_rules/ /usr/local/etc/lists/ /usr/local/etc/snort_custom/ /var/log/snort/ && \
    touch /usr/local/etc/rules/local.rules && \
    touch /usr/local/etc/lists/default.blocklist

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run snort   
ENTRYPOINT ["/entrypoint.sh"]