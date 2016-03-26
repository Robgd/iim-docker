#!/usr/bin/env bash

set -e

# Colors
COL_RESET=$'\e[39;49;00m'
RED=$'\e[31;01m'
GREEN=$'\e[32;01m'
YELLOW=$'\e[33;01m'
BLUE=$'\e[34;01m'
MAGENTA=$'\e[35;01m'
CYAN=$'\e[36;01m'

# @info:    Prints error messages
# @args:    error-message
echoError ()
{
  echo "\033[0;31mFAIL\n\n$1 \033[0m"
}

# @info:    Prints warning messages
# @args:    warning-message
echoWarn ()
{
  echo "\033[0;33m$1 \033[0m"
}

# @info:    Prints success messages
# @args:    success-message
echoSuccess ()
{
  echo "\033[0;32m$1 \033[0m"
}

# @info:    Prints check messages
# @args:    success-message
echoInfo ()
{
  printf "\033[1;34m[INFO] \033[0m$1"
}

# @info:    Prints property messages
# @args:    property-message
echoProperties ()
{
  echo "\t\033[0;35m- $1 \033[0m"
}

DOCKER_PATH=$HOME/docker
YOOPIES_PATH=$HOME/www/yoopies

install_github_ssh_key() {
    while true; do
    read -p "${GREEN} - Enter your github email address: ${COL_RESET}" email
    case $email in
        ?*@?*.?* ) ssh-keygen -t rsa -b 4096 -C "$email"; break;;
        * ) echo "      ${RED}Please enter a valid email${COL_RESET}";;
    esac
    done

    echo
    echo

    ssh-add ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub

    echo

    while true; do
        read -p "${GREEN} - Now copy past your ssh-rsa into github (see https://help.github.com/articles/generating-ssh-keys/#step-4-add-your-ssh-key-to-your-account) and press enter when its done !${COL_RESET} " yn
        case $yn in
            * ) break;;
        esac
    done

    ssh -T git@github.com

    break
}

echoInfo "======================================================"
echoInfo "=============== Install Symfony2 stack ==============="
echoInfo "======================================================"

#
# Check if Homebrew is installed
#
which -s brew
if [[ $? != 0 ]] ; then
    # Install package manager on mac osx call homebrew
    # https://github.com/mxcl/homebrew/wiki/installation
    echoInfo "==> Install Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    # Make sure brew is up to date
    brew update && brew upgrade
    echoSuccess "======= Done ! ======="
fi

echoInfo "==> Install brew-cask"
# Homebrew Cask extends Homebrew and brings its elegance, simplicity, and speed to OS X applications and large binaries alike.
brew tap caskroom/cask
brew install brew-cask
echoSuccess "======= Done ! ======="

echoInfo "==> Install Virtualbox"
brew cask install virtualbox
echoSuccess "======= Done ! ======="

echoInfo "==> Install some libraries with brew"
# Install amazon web services command cli
brew install awscli
brew install wget
brew install git
brew install docker
brew install docker-compose
brew install docker-machine
brew install gettext
brew link --force gettext
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
echoSuccess "======= Done ! ======="

echoInfo "==> Install docker-machine nfs script"
sudo cp docker-machine-nfs.sh /usr/local/bin/docker-machine-nfs
sudo chmod +x /usr/local/bin/docker-machine-nfs
echoSuccess "======= Done ! ======="

while true; do
    read -p "${GREEN} - Do you have a github account ? [y/n]${COL_RESET} " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echoWarn "Please create one before continue";;
        * ) echo "Please answer y (yes) or n (no).";;
    esac
done

while true; do
    read -p "${GREEN} - Do you have a ssh key configured ? [y/n]${COL_RESET} " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) install_github_ssh_key;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "${GREEN} - Do you have access to Yoopies project on Github ? [y/n]${COL_RESET} " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echoWarn "Ask to admin to give access";;
        * ) echo "Please answer yes or no.";;
    esac
done

cp ./.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

echo "${YELLOW}==> Cloning Yoopies project into $YOOPIES_PATH${COL_RESET}"
if [ ! -d "$YOOPIES_PATH" ] ; then
    mkdir ~/www
    git clone git@github.com:Yoopies/Yoopies.git $YOOPIES_PATH
fi
cp ./ips.php $YOOPIES_PATH/web
echo "${GREEN}======= Done ! =======${COL_RESET}"

echo "${YELLOW}==> Cloning Yoopies Docker project into $HOME/docker/yoopiesdocker${COL_RESET}"
if [ ! -d "$DOCKER_PATH" ] ; then
    mkdir ~/docker
    git clone git@github.com:Yoopies/YoopiesDocker.git $DOCKER_PATH/yoopiesdocker
fi
echo "${GREEN}======= Done ! =======${COL_RESET}"

cd $DOCKER_PATH/yoopiesdocker
sh config_env.sh $YOOPIES_PATH $DOCKER_PATH $(id -u)
echo "${YELLOW}==> Create docker machine dev ${COL_RESET}"
sh create-machine.sh
echo "${YELLOW}==> Mount local path to doker-machine please wait ... ${COL_RESET}"
sleep 5
docker-machine-nfs dev --shared-folder=$HOME --nfs-config="-alldirs -maproot=0"
echo "${GREEN}======= Done ! =======${COL_RESET}"

echo "${YELLOW}==> Install oh my zsh${COL_RESET}"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp ./zsh_aliases ~/.zsh_aliases
echo ". ~/.zsh_aliases" >> ~/.zshrc
echo "${GREEN}======= Done ! =======${COL_RESET}"