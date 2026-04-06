FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y python2 python2-dev openssl authbind gcc wget git vim iproute2 && \
    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py --no-check-certificate && \
    python2 get-pip.py && \
    rm get-pip.py

RUN touch /etc/authbind/byport/22 && \
    chmod 777 /etc/authbind/byport/22

RUN pip2 install Twisted==15.2.1 pycrypto pyasn1

RUN useradd -d /home/kippo -s /bin/bash -m kippo -g sudo && \
    chown kippo /etc/authbind/byport/22

USER kippo
WORKDIR /home/kippo

RUN git clone https://github.com/desaster/kippo.git

WORKDIR /home/kippo/kippo

RUN cp kippo.cfg.dist kippo.cfg && \
    sed -i 's/ssh_port = 2222/ssh_port = 22/g' kippo.cfg && \
    sed -i 's/twistd -y kippo.tac/authbind --deep twistd -n -y kippo.tac/g' start.sh

CMD ["./start.sh"]
