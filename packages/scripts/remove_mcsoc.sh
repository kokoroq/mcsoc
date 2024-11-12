#!/bin/bash
########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                       MCSOC Script
#                      Remove container
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.0
########################################################################

# Remove a container
func_remove_cont () {
    CHECK_SQLDATA=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
    select NAME = "$1" from container;
END`
    if [ $CHECK_SQLDATA -eq 0 ]; then
        echo "Not exist container"
        exit 1
    fi

    echo "----- Delete container -----"

    # Remove container & volume
    echo "[REMOVE]  Delete container, volume & network"
    cd /var/lib/mcsoc/mcsoc_archive/$1
    docker compose down -v
    if [ $? -ne 0 ]; then
        docker stop $1
        docker rm $1
        docker volume rm $1
        docker network rm pj-${1}_default
    fi
    cd ~

    # Move archive directory to trash
    echo "[MOVE]    container configuration files to trash directory"
    test -d /var/lib/mcsoc/mcsoc_archive/$1
    if [ $? -eq 0 ]; then
        rm -rf /var/lib/mcsoc/mcsoc_archive/$1/mcsv/app/*
        mv /var/lib/mcsoc/mcsoc_archive/$1/ /var/lib/mcsoc/mcsoc_archive/old/
    fi

    # Remove cron job
    BACKUP_PARAM=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
    select BACKUP from container where NAME = "$1";
END`
    if [ $BACKUP_PARAM = "Enable" ]; then
        echo "[DELETE]  Delete cron job"
        crontab -l > rm.crontab
        sed -i -e "/$1/d" rm.crontab
        crontab rm.crontab
        rm -f rm.crontab
    fi

    # Remove data of DB
    echo "[DELETE]  Delete container information"
    sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
    delete from container where NAME = "$1";
END

    echo "----------------------------"
    echo "Successfully remove container!"
}

# Remove all containers
func_remove_cont_all () {
    echo "< ATTENTION! >"
    echo "This command will delete 'ALL' containers."
    read -p "Do you really want to delete? [y/n] >" REMOVE_AGREEMENT

    if [[ $REMOVE_AGREEMENT != [yY]* ]]; then
        echo "Abort delete container"
        sleep 2
        exit 0
    fi

    # Read the number of containers
    COUNT_CONTAINERS=`echo "select count(*) from container" | sqlite3 /var/lib/mcsoc/mcsoc.sqlite3`
    
    # Repeat
    while [ $COUNT_CONTAINERS -ne 0 ]; do
        GET_CONTAINER_NAME=`echo "select NAME from container where ID = $COUNT_CONTAINERS" | sqlite3 /var/lib/mcsoc/mcsoc.sqlite3`

        echo "--- Start to delete \'$GET_CONTAINER_NAME\' ---"

        # Remove container & volume
        echo "[REMOVE]  Delete container, volume & network"
        cd /var/lib/mcsoc/mcsoc_archive/$GET_CONTAINER_NAME
        docker compose down -v
        if [ $? -ne 0 ]; then
            docker stop $GET_CONTAINER_NAME >/dev/null 2>&1
            docker rm $GET_CONTAINER_NAME
            docker volume rm $GET_CONTAINER_NAME
            docker network rm pj-${GET_CONTAINER_NAME}_default
        fi
        cd ~

        # Move archive directory to trash
        echo "[MOVE]    container configuration files to trash directory"
        test -d /var/lib/mcsoc/mcsoc_archive/$GET_CONTAINER_NAME
        if [ $? -eq 0 ]; then
            rm -rf /var/lib/mcsoc/mcsoc_archive/$GET_CONTAINER_NAME/mcsv/app/*
            mv /var/lib/mcsoc/mcsoc_archive/$GET_CONTAINER_NAME/ /var/lib/mcsoc/mcsoc_archive/old/
        fi

        # Remove cron job
        BACKUP_PARAM=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
        select BACKUP from container where NAME = "$GET_CONTAINER_NAME";
END`
        if [ $BACKUP_PARAM = "Enable" ]; then
            echo "[DELETE]  Delete cron job"
            crontab -l > rm.crontab
            sed -i -e "/$GET_CONTAINER_NAME/d" rm.crontab
            crontab rm.crontab
            rm -f rm.crontab
        fi

        # Remove data of DB
        echo "[DELETE]  Delete container information"
        sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
        delete from container where NAME = "$GET_CONTAINER_NAME";
END
        echo "--- Complete to delete '$GET_CONTAINER_NAME' ---"

        COUNT_CONTAINERS=`expr "$COUNT_CONTAINERS" - 1`
    done

    echo "---------------------------------------------------------"
    echo "END TO DELETE ALL CONTAINER"
}

# Remove all images
func_remove_image () {
    echo "[DELETE]  Delete all images"
    docker rmi `docker images -q` >/dev/null 2>&1

    echo "Successfully remove images!"
}


##################################################################
#                               Main                             #
##################################################################
case $1 in
    -rc ) if [ "$2" = "all" ]; then func_remove_cont_all; else func_remove_cont $2; fi ;;
    -ri ) func_remove_image ;;
esac