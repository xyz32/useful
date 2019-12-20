#!/bin/bash

set -x

#USER INPUT
SERVER_ADDR=${1}

FILTER="not port 22"

resetSSHKey ()
{
     IP=`resolveip -s ${1}`
     if [ $? -eq 0 ]; then
         ssh-keygen -R ${IP}
     fi
    
    IP=${1}

    ssh-keygen -R ${1}
    ssh-keyscan -H ${1} >> ~/.ssh/known_hosts

}

main ()
{
    rm -rf /tmp/remote
    
    IFHANDLER="remoteIO"
    
    INTERFACES=""
    mkdir -p /tmp/remote
        
    mkfifo /tmp/remote/${IFHANDLER}
    INTERFACES="${INTERFACES} -i /tmp/remote/${IFHANDLER}"
    
    ssh ${SERVER_ADDR} "sudo tcpdump -s 0 -U -n -w - -i any ${FILTER}" > /tmp/remote/${IFHANDLER} &
    
    sleep 1
    
    #dumpcap -t ${INTERFACES} -w /var/tmp/out.pcap
    
    sudo wireshark -k ${INTERFACES}
    
    #cleanup all background processes
    trap 'kill $(jobs -p)' EXIT
}

main
