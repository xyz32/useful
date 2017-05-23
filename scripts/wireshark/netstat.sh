#!/bin/bash

#USER INPUT
SERVER_ADDR=${1}
PASS=${2}

FILTER="not port 22"

resetSSHKey ()
{
     IP=`resolveip -s ${1}`
     if [ $? -eq 0 ]; then
         ssh-keygen -R ${IP}
     fi
    
    IP=${1}
    set -e
    ssh-keygen -R ${1}
    ssh-keyscan -H ${1} >> ~/.ssh/known_hosts
    set +e
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

    set -x
    for i in ${NODE_LIST[@]}; do
        sshpass -p ${PASS} ssh root@${SERVER_ADDR} "ssh ${i} echo \"\" > /tmp/netstat_${i}.txt"
        sshpass -p ${PASS} ssh root@${SERVER_ADDR} "ssh ${i} \"bash -c 'while true; do netstat -anp | grep 7800 >> /tmp/netstat_${i}.txt; echo \"----------------\"  >> /tmp/netstat_${i}.txt; sleep 1; done'\"" &
    done
    set +x

    #dumpcap -t ${INTERFACES} -w /var/tmp/out.pcap
    
    #wireshark -k ${INTERFACES}
    
    read -p "Press any key to terminate... " -n1 -s
    
    #cleanup all background processes
    trap 'kill $(jobs -p)' EXIT
}

main