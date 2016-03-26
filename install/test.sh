#!/usr/bin/env bash

# Colors
COL_RESET=$'\e[39;49;00m'
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
CYAN=$'\e[36m'

DOCKER_PATH=$HOME/docker
YOOPIES_PATH=$HOME/www/yoopies

echo $1
echo $2
echo $3

#cd $DOCKER_PATH/yoopiesdocker
#sh config_env.sh $YOOPIES_PATH $DOCKER_PATH
#echo "${YELLOW}==> Create docker machine dev ${COL_RESET}"
#sh create-machine.sh
#sudo docker-machine-nfs
#echo "${GREEN}======= Done ! =======${COL_RESET}"

#echo "${YELLOW}==> Install oh my zsh${COL_RESET}"
#sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
#echo ". ~/.zsh_aliases" >> ~/.zshrc
#echo "${GREEN}======= Done ! =======${COL_RESET}"

#mkdir ~/docker
#echo "${YELLOW}==> Cloning Yoopies Docker project into $HOME/docker/yoopiesdocker${COL_RESET}"
#git clone git@github.com:Yoopies/YoopiesDocker.git $DOCKER_PATH
#echo "${GREEN}======= Done ! =======${COL_RESET}"

#test() {
#    while true; do
#        read -p "${GREEN} - Now copy past your ssh-rsa into github and press enter when its done !${COL_RESET} " yn
#        case $yn in
#            * ) break;;
#        esac
#    done
#    break
#}
#while true; do
#    read -p "${GREEN} - Do you have a github account and ssh key configured ? [y/n]${COL_RESET} " yn
#    case $yn in
#        [Yy]* ) break;;
#        [Nn]* ) test;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
#
#while true; do
#    read -p "${GREEN} - Enter your email address: ${COL_RESET}" email
#    case $email in
#        ?*@?*.?* ) echo "$email"; break;;
#        * ) echo "      ${RED}Please enter a valid email${COL_RESET}";;
#    esac
#done