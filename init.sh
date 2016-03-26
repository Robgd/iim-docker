#!/bin/bash

eval "$(docker-machine env dev)"

docker build -t yoopies/ubuntu custom-ubuntu
sh rebuild.sh