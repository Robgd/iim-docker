#!/usr/bin/env bash

chown -R docker:docker /opt/iim

mkdir /tmp/sandbox
mkdir /tmp/mangopay

chown docker:docker /tmp/sandbox /tmp/mangopay

service php5-fpm start

tail -f /dev/null