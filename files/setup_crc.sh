#!/bin/bash 
set -xe

#export PATH=/home/admin/crc-linux-1.8.0-amd64:$PATH
/usr/local/bin/crc config set consent-telemetry yes| tee -a /tmp/crc_setup.log
/usr/local/bin/crc config set  nameserver ${1} | tee -a /tmp/crc_setup.log
/usr/local/bin/crc config set network-mode system
/usr/local/bin/crc setup | tee -a /tmp/crc_setup.log