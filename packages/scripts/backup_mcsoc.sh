#!/bin/bash

########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                       MCSOC Script
#                      Backup container
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.0
########################################################################

# read system files
source /etc/mcsoc/mcsoc.conf

# Time
TIME=`date "+%Y%m%d_%H%M%S"`

# Set edition
EDITION_NAME=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
select EDITION from container where NAME = "$2"
END`

# Set version
VERSION_INFO=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
select VERSION from container where NAME = "$2"
END`

# Set Memory
MS_JAVA_MEM=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
select MEMORY from container where NAME = "$2"
END`

#----------------------------------#
# Backup process
#----------------------------------#

#########################################
# Full backup
#########################################
full_backup () {
    echo "--- Full Backup for $1 container ---"
    echo "[LOTATE]  Check & Delete Backup file lotate"
    bkcount=`ls -1U /backup/ms/$1/full | wc -l`
    if [ $bkcount -gt $FULL_BACKUP_ROTATE ]; then
        ls -1U -tr /backup/ms/$1/full | head -1 | xargs -I {} rm -f /backup/ms/$1/full/{}
    fi

    stopcount=0

    # If the container is not running, start it
    online=`docker inspect --format='{{.State.Status}}' $1`
    if [ $online != "running" ]; then
        echo "[START]   Start the $1 container..."
        /usr/local/bin/mcsoc start $1 > /dev/null
        stopcount=1
    fi

    # Stop Minecraft server
    echo "[STOP]    Stop Minecraft server"
    docker exec -d $1 /usr/bin/tmux send-keys -t MCSV "say The Server stops after 10 seconds. Please SAVE immediately!" C-m
    sleep 10
    docker exec -d $1 /usr/bin/tmux send-keys -t MCSV "stop" C-m
    sleep 10

    
    # Start full backup
    echo "--- Duplicating ---"
    echo "[BACKUP]  Start FULL backup"
    if [ $EDITION_NAME = "Java" ]; then
        FULLBK_DIR="minecraft_java_server_full_backup_$TIME"
    else
        FULLBK_DIR="minecraft_be_server_full_backup_$TIME"
    fi
    mkdir /backup/ms/$1/full/$FULLBK_DIR
    if [ $EDITION_NAME = "Java" ]; then
        docker cp -q $1:/opt/minecraft/java/. /backup/ms/$1/full/$FULLBK_DIR
    else
        docker cp -q $1:/opt/minecraft/be/. /backup/ms/$1/full/$FULLBK_DIR
        rm -f /backup/ms/$1/full/$FULLBK_DIR/bedrock-server-*.zip
    fi

    if [ ! -e /backup/ms/$1/full/$FULLBK_DIR/version_info.txt ]; then
        touch /backup/ms/$1/full/$FULLBK_DIR/version_info.txt
        echo $VERSION_INFO > /backup/ms/$1/$FULLBK_DIR/version_info.txt
    fi
    tar -C /backup/ms/$1/full -zcf /backup/ms/$1/full/$FULLBK_DIR.tar.gz $FULLBK_DIR >/dev/null
    rm -rf /backup/ms/$1/full/$FULLBK_DIR

    # If the script shut down the Minecraft Server for backup, start it
    if [ $online = "running" ]; then
        echo "[Restart] Restart Minecraft server!"
        if [ $EDITION_NAME = "Java" ]; then
            docker exec -d $1 /usr/bin/tmux send-keys -t MCSV "java -Xmx${MS_JAVA_MEM} -Xms${MS_JAVA_MEM} -jar *.jar nogui" C-m
        else
            docker exec -d $1 /usr/bin/tmux send-keys -t MCSV "LD_LIBRARY_PATH=. ./bedrock_server" C-m
        fi
    fi

    # If the script start the container, stop it
    if [ $stopcount -eq 1 ]; then
        echo "[STOP]    Stop the $1 container..."
        docker stop $1 > /dev/null
    fi
    
    # Finish
    echo "========================================================================="
    echo "[DONE]    Finish FULL backup"
    echo "========================================================================="
}

#########################################
# Instant backup
#########################################
instant_backup () {
    echo "--- Instant Backup for $1 container ---"
    echo "[LOTATE]  Check & Delete Backup file lotate"
    bkcount=`ls -1U /backup/ms/$1/instant | wc -l`
    if [ $bkcount -gt $INSTANT_BACKUP_ROTATE ]; then
        ls -1U -tr /backup/ms/$1/instant | head -1 | xargs -I {} rm -f /backup/ms/$1/instant/{}
    fi

    # If the container is not running, skip instant backup
    online=`docker inspect --format='{{.State.Status}}' $1`
    if [ $online != "running" ]; then
        echo "[SKIP]    $1 is not running"
        echo "Skip instant backup..."
        exit 0
    fi

    # Start instant backup
    echo "--- Duplicating ---"
    echo "[BACKUP]  Start INSTANT backup"
    if [ $EDITION_NAME = "Java" ]; then
        INSTANTBK_DIR="minecraft_java_server_instant_backup_$TIME"
    else
        INSTANTBK_DIR="minecraft_be_server_instant_backup_$TIME"
    fi
    mkdir /backup/ms/$1/instant/$INSTANTBK_DIR
    if [ $EDITION_NAME = "Java" ]; then
        # whitelist.json
        docker cp -q $1:/opt/minecraft/java/whitelist.json /backup/ms/$1/instant/$INSTANTBK_DIR
        # banned-ips.json
        docker cp -q $1:/opt/minecraft/java/banned-ips.json /backup/ms/$1/instant/$INSTANTBK_DIR
        # banned-players.json
        docker cp -q $1:/opt/minecraft/java/banned-players.json /backup/ms/$1/instant/$INSTANTBK_DIR
        # server.properties
        docker cp -q $1:/opt/minecraft/java/server.properties /backup/ms/$1/instant/$INSTANTBK_DIR
        # ops.json
        docker cp -q $1:/opt/minecraft/java/ops.json /backup/ms/$1/instant/$INSTANTBK_DIR
        # usercache.json
        docker cp -q $1:/opt/minecraft/java/usercache.json /backup/ms/$1/instant/$INSTANTBK_DIR
        # worlds
        docker cp -q $1:/opt/minecraft/java/world /backup/ms/$1/instant/$INSTANTBK_DIR
        # logs
        docker cp -q $1:/opt/minecraft/java/logs /backup/ms/$1/instant/$INSTANTBK_DIR
    else
        # allowlist.json
        docker cp -q $1:/opt/minecraft/be/allowlist.json /backup/ms/$1/instant/$INSTANTBK_DIR
        # Dedicated_Server.txt
        docker cp -q $1:/opt/minecraft/be/Dedicated_Server.txt /backup/ms/$1/instant/$INSTANTBK_DIR
        # packet-statistics.txt
        docker cp -q $1:/opt/minecraft/be/packet-statistics.txt /backup/ms/$1/instant/$INSTANTBK_DIR
        # server.properties
        docker cp -q $1:/opt/minecraft/be/server.properties /backup/ms/$1/instant/$INSTANTBK_DIR
        # valid_known_packes.json
        docker cp -q $1:/opt/minecraft/be/valid_known_packs.json /backup/ms/$1/instant/$INSTANTBK_DIR
        # worlds
        docker cp -q $1:/opt/minecraft/be/worlds /backup/ms/$1/instant/$INSTANTBK_DIR
    fi
    tar -C /backup/ms/$1/instant -zcf /backup/ms/$1/instant/$INSTANTBK_DIR.tar.gz $INSTANTBK_DIR >/dev/null
    rm -rf /backup/ms/$1/instant/$INSTANTBK_DIR

    # Finish
    echo "========================================================================="
    echo "[DONE]    Finish INSTANT backup"
    echo "========================================================================="
}

case $1 in
    full ) full_backup $2 ;;
    instant ) instant_backup $2 ;;
    * ) echo "Invalid argument"; /usr/local/bin/mcsoc -h ;;
esac