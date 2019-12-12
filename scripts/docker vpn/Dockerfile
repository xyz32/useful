FROM fedora:29

RUN dnf -y update
RUN dnf -y install iproute openconnect net-tools

COPY connect.sh /opt/

WORKDIR /opt

ENTRYPOINT /bin/sh /opt/connect.sh
