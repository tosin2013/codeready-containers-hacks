#!/bin/bash 
set -xe

#export PATH=/home/admin/crc-linux-1.8.0-amd64:$PATH
/usr/local/bin/crc config set consent-telemetry yes| tee /tmp/crc_setup.log
/usr/local/bin/crc config set  nameserver ${1} | tee /tmp/crc_setup.log
/usr/local/bin/crc config set network-mode system
/usr/local/bin/crc setup | tee /tmp/crc_setup.log