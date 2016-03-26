#!/usr/bin/env bash

set -e

# /!\ Ceci est un script d'installation prévu pour des personnes n'ayant rien de configuré sur leur machine
# /!\ Adaptez ce script en fonction de vos besoins avant de le lancer.

# Lancer ce script depuis la racine de YoopiesDocker :
# ./install/linux-install.sh

# Colors
COL_RESET=$'\e[39;49;00m'
RED=$'\e[31;01m'
GREEN=$'\e[32;01m'
YELLOW=$'\e[33;01m'
BLUE=$'\e[34;01m'
MAGENTA=$'\e[35;01m'
CYAN=$'\e[36;01m'

DOCKER_PATH=`pwd`
YOOPIES_PATH=/var/www/yoopies

## Make sure dependencies are up to date
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install wget -y
sudo apt-get install curl -y
sudo apt-get install php5 -y

echo "${YELLOW}==> Install virtualbox"
sudo apt-get install virtualbox -y
echo "${GREEN}======= Done ! =======${COL_RESET}"

echo "${YELLOW}==> Install some libraries${COL_RESET}"
## Install amazon web services command cli
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

sudo apt-get install nfs-common
sudo apt-get install nfs-kernel-server

wget -qO- https://get.docker.com/ | sh

curl -L https://github.com/docker/machine/releases/download/v0.5.6/docker-machine_linux-amd64 > docker-machine-local
sudo mv docker-machine-local /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine

docker-machine version

curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > docker-compose-local
sudo mv docker-compose-local /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

docker-compose --version

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
echo "${GREEN}======= Done ! =======${COL_RESET}"

echo "${YELLOW}==> Install docker-machine nfs script${COL_RESET}"
sudo cp install/docker-machine-nfs-linux.sh /usr/local/bin/docker-machine-nfs
sudo chmod +x /usr/local/bin/docker-machine-nfs
echo "${GREEN}======= Done ! =======${COL_RESET}"

sed -e "s/\$USER_ID/$(id -u)/g" custom-ubuntu/Dockerfile.dist > custom-ubuntu/Dockerfile

cp install/.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

echo "${YELLOW}==> Cloning Yoopies project into $YOOPIES_PATH${COL_RESET}"
sudo mkdir -p $YOOPIES_PATH
sudo chown $USER:$USER $YOOPIES_PATH
git clone git@github.com:Yoopies/Yoopies.git $YOOPIES_PATH
cp install/ips.php $YOOPIES_PATH/web
sudo mkdir -p $YOOPIES_PATH/app/cache $YOOPIES_PATH/app/logs
sudo chown $USER:$USER $YOOPIES_PATH/app/cache $YOOPIES_PATH/app/logs
echo "${GREEN}======= Done ! =======${COL_RESET}"

echo "${YELLOW}==> Install oh my zsh${COL_RESET}"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp install/zsh_aliases ~/.zsh_aliases
echo ". ~/.zsh_aliases" >> ~/.zshrc
echo "${GREEN}======= Done ! =======${COL_RESET}"

./config_env.sh $YOOPIES_PATH $DOCKER_PATH $(id -u)
echo "${YELLOW}==> Create docker machine dev ${COL_RESET}"
./create-machine.sh
echo "${YELLOW}==> Mount local path to docker-machine please wait ... ${COL_RESET}"
sleep 5
sudo docker-machine-nfs $YOOPIES_PATH $DOCKER_PATH
echo "${GREEN}======= Done ! =======${COL_RESET}"

mkdir -p $DOCKER_PATH/yoopies/redis
sudo cp redis/dump.rdb $DOCKER_PATH/yoopies/redis
