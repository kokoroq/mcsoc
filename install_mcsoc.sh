#!/bin/bash

########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                      MCSOC Install Tool
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.0
########################################################################
#
# This script is a setup script for MCSOC
#
#------#
# USAGE
#------#
#
# To install MCSOC
# ./install_mcsoc.sh
#

# read mcsoc.conf
source ./packages/etc/mcsoc.conf

#---------------------------------------------------------------#
# VARS
#---------------------------------------------------------------#

# mcso installer directory path
mcsoc_installer_path=$(cd $(dirname $0);pwd)

# Login user
USERNAME=`logname`

#---------------------------------------------------------------#


#################################################################
#                           Setup 
#################################################################

# Welcome message
clear
echo "*****************************************************************************"
echo "*** Welcome to Minecraft Complex Server Operator for Container (MCSOC)!   ***"
echo "***                                                                       ***"
echo "*** Version: $VERSION                                                     ***"
echo "*****************************************************************************"
echo -e ""
echo "USERNAME:     $USERNAME"
echo "USERGROUP:    $USERNAME"
echo -e ""
read -p "[1] Do you want to add logged-in user to the docker group? *OPTION [y/n] > " ADD_GROUP_DOCKER
echo "-----"
echo "[2] Is your operating system Ubuntu or RHEL compatible(EL)?"
read -p "(ubuntu/el) Default is ubuntu > " selectos
if [ "$selectos" = "ubuntu" ] || [ "$selectos" = "" ]; then
    selectos="Ubuntu"
elif [ "$selectos" = "el" ]; then
    selectos="EL"
else
    echo "Invalid OS name, Please retry to run"
    exit 1
fi
echo "----- Input Result -----"
echo ""
echo "- OS:               $selectos"
echo "- Add docker group: $ADD_GROUP_DOCKER"
echo ""
read -p "<!> Start install MCSOC? [y/n] > " IGNITION_INSTALL

if [[ $IGNITION_INSTALL != [yY]* ]]; then
    echo "Abort MCSOC install"
    sleep 2
    exit 0
fi 


echo "----- Start Install -----"

#-----------------------------------------------------------------#
# User join docker group
#-----------------------------------------------------------------#

if [ $ADD_GROUP_DOCKER = "y" ] || [ $ADD_GROUP_DOCKER = "yes" ]; then
    echo "[JOIN]        $USERNAME add docker group"
    CHECK_GROUP_DOCKER=`cat /etc/group | grep docker | wc -l`
    if [ $CHECK_GROUP_DOCKER -eq 0 ]; then
        sudo groupadd docker
    fi
    sudo usermod -aG docker $USERNAME
    echo "Successfully add docker group"
fi

#-----------------------------------------------------------------#
# Create directory
#-----------------------------------------------------------------#
echo "[CREATE]      MCSOC directory"

test -d /opt/mcsoc/
if [ $? = 1 ];then sudo mkdir -p /opt/mcsoc/;fi
sudo chown -R $USERNAME:$USERNAME /opt/mcsoc/

test -d /opt/mcsoc/scripts/
if [ $? = 1 ];then sudo mkdir -p /opt/mcsoc/scripts/;fi
sudo chown -R $USERNAME:$USERNAME /opt/mcsoc/scripts/

test -d  /opt/mcsoc/docker/
if [ $? = 1 ];then sudo mkdir -p  /opt/mcsoc/docker/;fi
sudo chown -R $USERNAME:$USERNAME  /opt/mcsoc/docker/

test -d /var/lib/mcsoc/
if [ $? = 1 ];then sudo mkdir -p /var/lib/mcsoc/;fi
sudo chown -R $USERNAME:$USERNAME /var/lib/mcsoc/

test -d /var/lib/mcsoc/mcsoc_archive/
if [ $? = 1 ];then sudo mkdir -p /var/lib/mcsoc/mcsoc_archive/;fi
sudo chown -R $USERNAME:$USERNAME /var/lib/mcsoc/mcsoc_archive/

test -d /var/lib/mcsoc/mcsoc_archive/old/
if [ $? = 1 ];then sudo mkdir -p /var/lib/mcsoc/mcsoc_archive/old/;fi
sudo chown -R $USERNAME:$USERNAME /var/lib/mcsoc/mcsoc_archive/old/

test -d /var/log/mcsoc/
if [ $? = 1 ];then sudo mkdir -p /var/log/mcsoc/;fi
sudo chown -R $USERNAME:$USERNAME /var/log/mcsoc/

test -d /etc/mcsoc/
if [ $? = 1 ];then sudo mkdir -p /etc/mcsoc/;fi
sudo chown -R $USERNAME:$USERNAME /etc/mcsoc/

test -d /backup/ms/
if [ $? = 1 ];then sudo mkdir -p /backup/ms/;fi
sudo chown -R $USERNAME:$USERNAME /backup/ms/

#-----------------------------------------------------------------#
# Install dependent packages
#-----------------------------------------------------------------#

# Require packages
#   - unzip
#   - wget
#   - tar
#   - cron
#   - sqlite3

echo "[INSTALL]     Dependent packages"

pkgs_count=0
if [ "$selectos" = "Ubuntu" ]; then
    # Ubuntu
    pkgs=("unzip" "tar" "cron" "wget" "sqlite3" "__EOF__")
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update >/dev/null
    while [ ${pkgs[$pkgs_count]} != "__EOF__" ]
    do
        pkgline=`dpkg -l ${pkgs[$pkgs_count]} | grep ${pkgs[$pkgs_count]} | wc -l` >/dev/null 2>&1
        if [ $pkgline -eq 0 ]; then
            if [ ${#pkgs_b_inst[*]} -eq 0 ]; then
                pkgs_b_inst+="cron ${pkgs[${pkgs_count}]}"
            else
                pkgs_b_inst+=" ${pkgs[${pkgs_count}]}"
            fi
        fi
        pkgs_count=`expr $pkgs_count + 1`
    done
    sudo apt-get -y install $pkgs_b_inst >/dev/null
elif [ "$selectos" = "EL" ]; then
    # EL
    pkgs=("unzip" "tar" "crontabs" "wget" "sqlite" "__EOF__")
    sudo dnf update >/dev/null
    while [ ${pkgs[$pkgs_count]} != "__EOF__" ]
    do
        pkgline=`dnf list installed | grep ${pkgs[$pkgs_count]} | wc -l`
        if [ $pkgline -eq 0 ]; then
            if [ $pkgs_count -eq 0 ]; then
                pkgs_b_inst+="${pkgs[${pkgs_count}]}"
            else
                pkgs_b_inst+=" ${pkgs[${pkgs_count}]}"
            fi
        fi
        pkgs_count=`expr $pkgs_count + 1`
    done
    sudo dnf -y install $pkgs_b_inst >/dev/null
fi


#-----------------------------------------------------------------#
# Create cron profile database
#-----------------------------------------------------------------#
echo "[CREATE]      cron profile database"
./tmp/make_cron_profile.sh

#-----------------------------------------------------------------#
# Create container database
#-----------------------------------------------------------------#
echo "[CREATE]      container database"
sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 \
'create table container(ID INTEGER PRIMARY KEY, NAME TEXT UNIQUE, EDITION TEXT, "HOST PORT" INTEGER, VERSION TEXT DEFAULT "NO DATA", BACKUP TEXT, MEMORY TEXT DEFAULT "NO DATA", NOTE TEXT)'

#-----------------------------------------------------------------#
# Install MCSOC
#-----------------------------------------------------------------#
echo "[INSTALL]     MCSOC package"

sudo cp -p ./packages/bin/mcsoc /usr/local/bin/
sudo chmod +x /usr/local/bin/mcsoc
sudo cp -rpT ./packages/scripts/  /opt/mcsoc/scripts/
sudo chmod +x /opt/mcsoc/scripts/backup_mcsoc.sh
sudo chown $USERNAME:$USERNAME /opt/mcsoc/scripts/backup_mcsoc.sh
sudo chmod +x /opt/mcsoc/scripts/create_mcsoc.sh
sudo chown $USERNAME:$USERNAME /opt/mcsoc/scripts/create_mcsoc.sh
sudo chmod +x /opt/mcsoc/scripts/remove_mcsoc.sh
sudo chown $USERNAME:$USERNAME /opt/mcsoc/scripts/remove_mcsoc.sh
sudo chmod +x /opt/mcsoc/scripts/update_mcsoc.sh
sudo chown $USERNAME:$USERNAME /opt/mcsoc/scripts/update_mcsoc.sh
sudo cp -p ./packages/etc/mcsoc.conf /etc/mcsoc/
sudo chown $USERNAME:$USERNAME /etc/mcsoc/mcsoc.conf
sudo cp -rpT ./packages/docker/ /opt/mcsoc/docker/
sudo chown -R $USERNAME:$USERNAME /opt/mcsoc/docker/

##### FINISH #####
echo "======================================================"
echo "[DONE]        MCSOC installation completed !!"
echo "Require reboot host"
echo "======================================================"