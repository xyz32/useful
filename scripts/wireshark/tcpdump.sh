#!/bin/bash

set -x

#USER INPUT
SERVER_ADDR=${1}
PASS=${2}

EXTRA_NODE_ADDR=${3}
EXTRA_NODE_PASS=${4}

SKIP_NODE=${5}

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

getNumberOfNodes()
{
    INPUT=$(sshpass -p ${PASS} ssh root@${SERVER_ADDR} "cmw-status -v node | grep safAmfNode")
    NODE_LIST=`awk '{
    n = split($0, t, "safAmfNode=")
        for (i = 1; ++i <= n;) {
            split(t[i], pl, ",")
            print pl[1]
        }
    }' <<< ${INPUT}`
}

main ()
{
    rm -rf /tmp/remote
    resetSSHKey ${SERVER_ADDR}
    
    getNumberOfNodes
    
    INTERFACES=""
    mkdir -p /tmp/remote
    
    for i in ${NODE_LIST[@]}; do
        
        if [ -n "${SKIP_NODE}" ]; then
                if [ "${SKIP_NODE}" == "${i}" ]; then
                        continue
                fi
        fi
        
        mkfifo /tmp/remote/${i}
        sshpass -p ${PASS} ssh root@${SERVER_ADDR} "ssh ${i} tcpdump -s 0 -U -n -w - -i any ${FILTER}" > /tmp/remote/${i} &
        INTERFACES="${INTERFACES} -i /tmp/remote/${i}"
    done
    
    if [ -n "${EXTRA_NODE_ADDR}" ]; then
        resetSSHKey ${EXTRA_NODE_ADDR}
        mkfifo /tmp/remote/EXTRA
        sshpass -p ${EXTRA_NODE_PASS} ssh root@${EXTRA_NODE_ADDR} "tcpdump -s 0 -U -n -w - -i any ${FILTER}" > /tmp/remote/EXTRA &
        INTERFACES="${INTERFACES} -i /tmp/remote/EXTRA"
    fi
    
    #dumpcap -t ${INTERFACES} -w /var/tmp/out.pcap
    
    wireshark -k ${INTERFACES}
    
    #cleanup all background processes
    trap 'kill $(jobs -p)' EXIT
}

main
