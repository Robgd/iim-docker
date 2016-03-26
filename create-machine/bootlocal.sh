#!/usr/bin/env bash

sudo umount /Users 2> /dev/null
sudo /usr/local/etc/init.d/nfs-client start 2> /dev/null
sudo mount 192.168.2.123:/Users /Users -o noatime,soft,nolock,vers=3,udp,proto=udp,rsize=8192,wsize=8192,namlen=255,timeo=10,retrans=3,nfsvers=3