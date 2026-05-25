###
# basic Installation of SnortML -> is bigger than the other
###

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install needed packages
RUN apt-get update && apt-get install -y \
    git cmake make g++ autoconf libtool pkg-config \
    libdumbnet-dev libhwloc-dev libluajit-5.1-dev \
    libssl-dev libpcap-dev libpcre2-dev zlib1g-dev liblzma-dev \
    flex uuid wget curl net-tools \
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
    make install

# -------------------------
# Build Snort3
# -------------------------
RUN git clone https://github.com/snort3/snort3.git && \
    cd snort3 && \
    ./configure_cmake.sh --prefix=/usr --enable-debug-msgs && \
    cd build && \
    make -j$(nproc) || make -j1 && \
    make install && \
    mv /usr/bin/snort /usr/sbin/snort
    
CMD ["snort", "-V"]
