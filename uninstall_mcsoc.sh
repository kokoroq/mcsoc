#!/bin/bash
#

########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2026 kokoroq. All rights reserved.
#
#
#                      MCSOC Uninstall Tool
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.1.0
########################################################################
#
# <!> ATTENTION
# Running this tool will ERASE all data related to MCSOC
#
# ( NOTE )
# It is RECOMMENDED to stop all container when uninstalling
#

# Set default param
usercfm="back"

# read mcso.conf
source /etc/mcsoc/mcsoc.conf

# Confirm to start uninstall process
clear
echo "*****************************************************"
echo " Minecraft Complex Server Operator for Container" 
echo " Uninstall Tool"
echo -e ""
echo "Current Version: $VERSION"
echo "*****************************************************"
echo -e ""
echo "<!> ATTENTION <!>"
echo "Running this tool will 'ERASE' all data related to MCSOC"
echo -e ""

echo "Start the uninstallation process"
echo "Do you really want to uninstall MCSOC?"
read -p "[agree/back] Default is back: " usercfm

if [ "$usercfm" != "agree" ]; then
    echo "Abort the process"
    sleep 2
    exit 0
fi

# If containers exist
CONT_NUM=$(docker ps -a 2>/dev/null | wc -l)
if [ $CONT_NUM -gt 1 ]; then
    echo -e ""
    echo "Containers exist"
    echo "To proceed with the uninstallation, delete all MCSOC containers."
    read -p "Continue to uninstall MCSOC? [y/n] > " check_cont

    if [[ $check_cont = [yY]* ]]; then
        mcsoc rm all
    else
        echo "Abort MCSOC install"
        sleep 2
        exit 0
    fi
fi

# If the container is running, stop it
docker stop $(docker ps -q) >/dev/null 2>&1


echo -e ""
echo " < When the dialog box of 'sudo' appears, please enter user password > "

# Uninstall files / 
echo "-----  Uninstall MCSOC  -----"

test -f /usr/bin/mcsoc
if [ $? = 0 ]; then
    echo "- Remove /usr/bin/mcsoc"
    sudo rm -f /usr/bin/mcsoc
fi

test -f /usr/bin/mcsocremote
if [ $? = 0 ]; then
    echo "- Remove /usr/bin/mcsocremote"
    sudo rm -f /usr/bin/mcsocremote
fi

test -d /opt/mcsoc/
if [ $? = 0 ]; then
    echo "- Remove /opt/mcsoc/"
    sudo rm -rf /opt/mcsoc/
fi

test -d /var/lib/mcsoc/
if [ $? = 0 ]; then
    echo "- Remove /var/lib/mcsoc/"
    cp /var/lib/mcsoc/mcsoc.sqlite3 /tmp/mcsoc.sqlite3.bk
    cp -r /var/lib/mcsoc/mcsoc_archive/ /tmp/
    rm -rf /tmp/mcsoc_archive/old/
    sudo rm -rf /var/lib/mcsoc/
fi

test -d /etc/mcsoc/
if [ $? = 0 ]; then
    echo "- Remove /etc/mcsoc/"
    sudo rm -rf /etc/mcsoc/
fi

test -f /usr/share/bash-completion/completions/_mcsoc
if [ $? = 0 ]; then
    echo "- Remove /usr/share/bash-completion/completions/_mcsoc"
    sudo rm -f /usr/share/bash-completion/completions/_mcsoc
fi

test -f /usr/share/bash-completion/completions/_mcsocremote
if [ $? = 0 ]; then
    echo "- Remove /usr/share/bash-completion/completions/_mcsocremote"
    sudo rm -f /usr/share/bash-completion/completions/_mcsocremote
fi

##### FINISH #####
echo "======================================================"
echo "          MCSOC uninstallation completed !!"
echo "======================================================"