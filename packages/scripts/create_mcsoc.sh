#!/bin/bash
########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                       MCSOC Script
#                      Create container
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.0
########################################################################

# read system files
source /etc/mcsoc/mcsoc.conf

# Login user
USERNAME=`logname`

TMP_APP_NAME=`basename $2`
if [ $1 = "java" ] || [ $1 = "Java" ] || [ $1 = "JAVA" ]; then
    EDITION_NAME="Java"
elif [ $1 = "be" ] || [ $1 = "Be" ] || [ $1 = "BE" ]; then
    EDITION_NAME="Bedrock"
else
    echo "Invalid edition name"
    exit 1
fi

if [[ $TMP_APP_NAME = *".zip" ]] || [[ $TMP_APP_NAME = *".jar" ]] || [[ $TMP_APP_NAME = "minecraft_"*".tar.gz" ]]; then
    
    clear
    echo "========================================================================="
    echo "===                        Create container                           ==="
    echo "========================================================================="
    echo "Follow the instructions on the display"
    echo ""
    read -p "[1] Enter container name > " READ_CONT_NAME
    if [[ $READ_CONT_NAME =~ .*(\.|\,|\-|\+|\*|\'|\"|\(|\)|\<|\>|\=|\^|\!|\/|\:|\;|\%|\||\[|\]) ]]; then
        echo "Contains invalid strings"
        echo "You cannot use SPECIAL CHARACTERS" 
        echo "Please try again"
        exit 1
    fi
    echo "-----"
    read -p "[2] Enter the host port used by the server > " READ_HOST_PORT
    echo "-----"
    read -p "[3] Do you want to enable the auto-start setting? [y/n] > " READ_AUTOSTART
    if [[ $READ_AUTOSTART = [yY]* ]]; then
        READ_AUTOSTART="Enable"
    else
        READ_AUTOSTART="Disable"
    fi
    echo "-----"
    read -p "[4] Do you want to enable scheduled backup? [y/n] > " READ_BACKUP
    if [[ $READ_BACKUP = [yY]* ]]; then
        READ_BACKUP="Enable"
    else
        READ_BACKUP="Disable"
    fi
    if [ $EDITION_NAME = "Java" ]; then
        echo "-----"
        read -p "[5] Enter the amount of memory used by the server (e.g. 1024M) > " READ_ASSIGN_MEM
    fi
    echo "-----"
    echo "Please make sure you have the correct information."
    echo -e ""
    echo "- Container name:   $READ_CONT_NAME" 
    echo "- Edition name:     $EDITION_NAME"
    echo "- Host port:        $READ_HOST_PORT"
    echo "- Auto-start:       $READ_AUTOSTART"
    echo "- Backup schedule:  $READ_BACKUP"
    if [ $EDITION_NAME = "Java" ]; then
        echo "- Amount memory:    $READ_ASSIGN_MEM"
    fi
    echo -e ""
    read -p "Okey? [y/n] > " CHECK_PARM1
    if [[ $CHECK_PARM1 != [yY]* ]]; then
        echo "Try again..."
        exit 1
    fi

    echo "========================================================================="

    # Copy config data
    echo "[COPY]    Copying container configuration files"
    mkdir -p /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME
    if [[ $TMP_APP_NAME = *".zip" ]]; then
        VERSION_INFO=`echo $TMP_APP_NAME | sed -r "s/bedrock-server-(.*)\.zip$/\1/"`
        if [ $VERSION_INFO = "" ]; then
            read -p  "Enter the Minecraft server version *OPTION*" VERSION_INFO
            if [ $VERSION_INFO = "" ]; then
                VERSION_INFO="NO DATA"
            fi
        fi
        cp -rT /opt/mcsoc/docker/new_install/be/ /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME
    elif [[ $TMP_APP_NAME = *".jar" ]]; then
        VERSION_INFO=`echo $TMP_APP_NAME | sed  -r "s/minecraft_server\.(.*)\.jar$/\1/"`
        if [ $VERSION_INFO = "" ]; then
            read -p  "Enter the Minecraft server version *OPTION*" VERSION_INFO
            if [ $VERSION_INFO = "" ]; then
                VERSION_INFO="NO DATA"
            fi
        fi
        cp -rT /opt/mcsoc/docker/new_install/java/ /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME
    elif [[ $TMP_APP_NAME = "minecraft_be_"*".tar.gz" ]]; then
        cp -rT /opt/mcsoc/docker/replica_install/be/ /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME
    elif [[ $TMP_APP_NAME = "minecraft_java_"*".tar.gz" ]]; then
        cp -rT /opt/mcsoc/docker/replica_install/java/ /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME
    fi
    
    if [[ $TMP_APP_NAME = "minecraft_"*".tar.gz" ]]; then
        # [If you use backup data] defreeze tar
        echo "[TAR]     Deployment server files"
        tar -zxf $2 -C /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app >/dev/null
        mv /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/minecraft_*_server_full_backup_*/* /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/
        rm -rf /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/minecraft_*_server_full_backup_*
        rm -rf $2
        if [ -e /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt ]; then
            VERSION_INFO=`head -n 1 /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt`
        elif [ -e /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/be_version.txt ]; then
            VERSION_INFO=`head -n 1 /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/be_version.txt`
            touch /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
            echo $VERSION_INFO > /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
            rm -f /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/be_version.txt
        elif [ -e /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/java_version.txt ]; then
            VERSION_INFO=`head -n 1 /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/java_version.txt`
            touch /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
            echo $VERSION_INFO > /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
            rm -f /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/java_version.txt
        else
            read -p  "Enter the Minecraft server version *OPTION*" VERSION_INFO
            if [ $VERSION_INFO = "" ]; then
                VERSION_INFO="NO DATA"
                touch /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
                echo $VERSION_INFO > /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
            fi
        fi
    else
        # Move application to container configration directory
        echo "[MOVE]    Deployment server files"
        mv $2 /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app
        if [ $EDITION_NAME = "Bedrock" ]; then
            unzip /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/bedrock-server*.zip -d /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/ >/dev/null 2>&1
        fi
        touch /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
        echo $VERSION_INFO > /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/app/version_info.txt
    fi

    # Add parameter in .env
    echo "[ADD]     Edit parameters"
    sed -i -e "s/COMPOSE_PROJECT_NAME=/COMPOSE_PROJECT_NAME=pj-$READ_CONT_NAME/" /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/.env
    sed -i -e "s/CONTAINER_NAME=/CONTAINER_NAME=$READ_CONT_NAME/" /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/.env
    sed -i -e "s/HOST_PORT=/HOST_PORT=$READ_HOST_PORT/" /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/.env
    if [ $READ_AUTOSTART = "Enable" ]; then
        sed -i -e "s/RESTART_PARAM=\"no\"/RESTART_PARAM=always/" /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/.env
    fi
    if [ "$1" = "java" ]; then
        sed -i -e "s/MS_JAVA_MEM=\"1024M\"/MS_JAVA_MEM=$READ_ASSIGN_MEM/" /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/.env
    fi
    if [[ $TMP_APP_NAME = "minecraft_java_"*".tar.gz" ]]; then
        for filenm in $MS_JAVA_DIR/*.jar
        do
            TMP_APP_NAME=`basename $filenm`
        done
    fi
    sed -i -e "s/ENV SET_USERNAME=/ENV SET_USERNAME=$USERNAME/" /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/mcsv/Dockerfile
    
    # Backup Configuration
    if [ $READ_BACKUP = "Enable" ]; then
        echo "[SET]     Schedule cron job of backup"

        # Set time parameter
        BK_MINUTE_FULL=`sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 "select MINUTE from bk_full_profile where ID = $FULL_BK_PROFILE"`
        BK_HOUR_FULL=`sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 "select HOUR from bk_full_profile where ID = $FULL_BK_PROFILE"`
        BK_WEEK_FULL=`sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 "select WEEK from bk_full_profile where ID = $FULL_BK_PROFILE"`
        BK_MINUTE_INSTANT=`sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 "select MINUTE from bk_instant_profile where ID = $INSTANT_BK_PROFILE"`
        BK_HOUR_INSTANT=`sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 "select HOUR from bk_instant_profile where ID = $INSTANT_BK_PROFILE"`
        BK_WEEK_INSTANT=`sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 "select WEEK from bk_instant_profile where ID = $INSTANT_BK_PROFILE"`

        # Entry cron configuration
        crontab -l > setup.crontab
        echo "$BK_MINUTE_FULL $BK_HOUR_FULL * * $BK_WEEK_FULL /usr/local/bin/mcsoc backup full $READ_CONT_NAME" >> setup.crontab
        echo "$BK_MINUTE_INSTANT $BK_HOUR_INSTANT * * $BK_WEEK_INSTANT /usr/local/bin/mcsoc backup instant $READ_CONT_NAME" >> setup.crontab
        crontab setup.crontab
        rm -f setup.crontab

        # Edit next parameter
        if [ $FULL_BK_PROFILE -eq 49 ]; then
            sed -i -e "s/FULL_BK_PROFILE=$FULL_BK_PROFILE/FULL_BK_PROFILE=1/" /etc/mcsoc/mcsoc.conf
        else
            NEXT_PROFILE=$(( $FULL_BK_PROFILE + 1 ))
            sed -i -e "s/FULL_BK_PROFILE=$FULL_BK_PROFILE/FULL_BK_PROFILE=$NEXT_PROFILE/" /etc/mcsoc/mcsoc.conf
        fi
        if [ $INSTANT_BK_PROFILE -eq 18 ]; then
            sed -i -e "s/INSTANT_BK_PROFILE=$INSTANT_BK_PROFILE/INSTANT_BK_PROFILE=1/" /etc/mcsoc/mcsoc.conf
        else
            NEXT_PROFILE=$(( $INSTANT_BK_PROFILE + 1 ))
            sed -i -e "s/INSTANT_BK_PROFILE=$INSTANT_BK_PROFILE/INSTANT_BK_PROFILE=$NEXT_PROFILE/" /etc/mcsoc/mcsoc.conf
        fi
    fi

    # Make backup & log directory
    echo "[MAKE]    Make Backup & Log directory"
    test -d /var/log/mcsoc/$READ_CONT_NAME
    if [ $? = 1 ]; then mkdir -p /var/log/mcsoc/$READ_CONT_NAME; fi
    test -d /backup/ms/$READ_CONT_NAME
    if [ $? = 1 ]; then
        mkdir -p /backup/ms/$READ_CONT_NAME/full
        mkdir -p /backup/ms/$READ_CONT_NAME/instant
    fi

    # Build image & Create container
    echo "[COMPOSE] Build image & Create container"
    cd /var/lib/mcsoc/mcsoc_archive/$READ_CONT_NAME/
    docker compose up --no-start

    # Add container information to DB
    echo "[DB]      Add detailed information of container"
    if [ $EDITION_NAME = "Java" ]; then
        sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
        insert into container(NAME, EDITION, 'HOST PORT', VERSION, BACKUP, MEMORY) values("$READ_CONT_NAME", "$EDITION_NAME", $READ_HOST_PORT, "$VERSION_INFO", "$READ_BACKUP", "$READ_ASSIGN_MEM");
END
    else
        sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
        insert into container(NAME, EDITION, 'HOST PORT', VERSION, BACKUP) values("$READ_CONT_NAME", "$EDITION_NAME", $READ_HOST_PORT, "$VERSION_INFO", "$READ_BACKUP");
END
    fi

    # Finish
    echo "========================================================================="
    echo "[DONE]    Created container"
    echo "If you use the server, run 'mcsoc' command to start container"
    echo "========================================================================="
else
    echo "Invalid application path"
    exit 1
fi