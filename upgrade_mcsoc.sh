#!/bin/bash

# read mcsoc.conf
source /etc/mcsoc/mcsoc.conf

### VARS ###

# Upgrade version
NEXT_VERSION=1.0.2

########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                      MCSOC Upgrade Tool
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.0.3
########################################################################

clear

# Check MCSOC installed
if [ ! -e /etc/mcsoc/mcsoc.conf ]; then
    echo "MCSOC is not installed"
    echo "To install MCSOC, run the 'install_mcsoc.sh'."
    exit 1
fi

echo "*****************************************"
echo "***               MCSOC               ***"
echo "***            Upgrade Tool           ***"
echo "***                                   ***"
echo "*** Current Version: $VERSION            ***"
echo "*** Upgrade Version: $NEXT_VERSION            ***"
echo "*****************************************"
echo ""
read -p "Do you want to upgrade MCSOC? [y/n] > " CHECK_UPGRADE

if [[ $CHECK_UPGRADE != [yY]* ]]; then
    echo "You must agree in order to upgrade"
    echo "Try again..."
    exit 1
fi

echo "-----  Start upgrade  -----"

#-----------------------------------------------------------------#
# Read current parameters
#-----------------------------------------------------------------#


#-----------------------------------------------------------------#
# Remove current files
#-----------------------------------------------------------------#
echo "[UNINSTALL]   Current version"

# Remove mcsoc command
sudo rm -f /usr/local/bin/mcsoc

# Remove mcsoc scripts
sudo rm -f /opt/mcsoc/scripts/*

# Remove docker configuration files
sudo rm -rf /opt/mcsoc/docker/*

# Remove mcsoc completion file
sudo rm -f /usr/share/bash-completion/completions/_mcsoc

#-----------------------------------------------------------------#
# Install additional packages
#-----------------------------------------------------------------#


#-----------------------------------------------------------------#
# Install new version
#-----------------------------------------------------------------#
echo "[INSTALL]     New version"

# Copy mcsoc command
sudo cp -p ./packages/bin/mcsoc /usr/local/bin/
sudo chmod +x /usr/local/bin/mcsoc

# Copy scripts
sudo cp -rpT ./packages/scripts/  /opt/mcsoc/scripts/
sudo chmod -R +x /opt/mcsoc/scripts/
sudo chown -R $USERNAME:$USERNAME /opt/mcsoc/scripts/

# Copy docker configuration
sudo cp -rpT ./packages/docker/  /opt/mcsoc/docker/
sudo chmod -R +x /opt/mcsoc/docker/
sudo chown -R $USERNAME:$USERNAME /opt/mcsoc/docker/

# Copy mcsoc completion file
sudo cp -p ./packages/etc/_mcsoc /usr/share/bash-completion/completions/

#-----------------------------------------------------------------#
# Edit parameter of conf
#-----------------------------------------------------------------#
echo "[EDIT]        Setting..."

# Edit version number
sed -i "/VERSION=/c VERSION=$NEXT_VERSION" /etc/mcsoc/mcsoc.conf



##### FINISH #####
echo "======================================================"
echo "[DONE]        MCSOC Upgrade completed !!"
echo "Upgrade Version:  $NEXT_VERSION"
echo "Require reboot host"
echo "======================================================"