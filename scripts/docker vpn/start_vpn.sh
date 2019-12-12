#!/bin/bash

if [[ "$(docker images -q cisco_vpn 2> /dev/null)" == "" ]]; then
    docker build -t cisco_vpn .
    docker create --name nuance_vpn --privileged -i -t --cap-add=NET_ADMIN --net=host cisco_vpn
fi
    
docker start -a -i nuance_vpn
docker stop nuance_vpn

#sudo docker run --name nuance_vpn --privileged -i -t --cap-add=NET_ADMIN --net=host cisco_vpn
#sudo docker run --privileged -i -t --cap-add=ALL --net=host cisco_vpn
