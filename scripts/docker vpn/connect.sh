#!/bin/sh

#openconnect
openconnect [server_URL] --csd-wrapper /usr/libexec/openconnect/csd-wrapper.sh

#route all traffic through tunnel:
#openconnect [server_URL] --csd-wrapper /usr/libexec/openconnect/csd-wrapper.sh --script 'unset CISCO_SPLIT_INC; /etc/vpnc/vpnc-script'
