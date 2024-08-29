#!/bin/bash

########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                       MCSOC Script
#                  Update Minecraft Server
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.0
########################################################################

#       VARS        #

# Set container name
CONTAINER_NAME=`head -n 1 /tmp/container_name.txt`
rm -f /tmp/container_name.txt

# Set edition
EDITION_NAME=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3<<END
select EDITION from container where NAME = "$CONTAINER_NAME";
END`

#####################

# Function for start
func_online_download () {
    # BE or JAVA 
    echo "Download appication from Internet"
    mkdir /tmp/update_dir >/dev/null 2>&1
    if [ "$EDITION_NAME" = "Bedrock" ]; then
        # Download process
        echo "Enter the 'URL' of the Minecraft Bedrock server application"
        read -p "> " be_url
        echo "Now Downloading..."
        wget -v -P /tmp/update_dir $be_url
        test -f /tmp/update_dir/bedrock-server*.zip
        if [ $? -eq 0 ];then
            echo "Download successfully!"
            app_name=`basename /tmp/update_dir/bedrock-server*.zip`
            VERSION_NAME=`echo $app_name | sed -r "s/bedrock-server-(.*)\.zip$/\1/"`
        else
            echo "Download failed..."
            echo "Stop update"
            rm -rf /tmp/update_dir
            sleep 2
            exit 1
        fi
    elif [ "$EDITION_NAME" = "Java" ]; then
        # Download process
        echo "Enter the version to download new minecraft server application"
        read -p "> " VERSION_NAME
        echo -e "\n"
        echo "Enter the 'URL' of the Minecraft Java server application"
        read -p "> " java_url
        echo "Now Downloading..."
        wget -v -P /tmp/update_dir $java_url
        test -f /tmp/update_dir/server.jar
        if [ $? -eq 0 ];then
            echo "Download successfully!"
            mv /tmp/update_dir/server.jar "/tmp/update_dir/minecraft_server."$VERSION_NAME".jar"
        else
            echo "Download failed..."
            echo "Stop update"
            rm -rf /tmp/update_dir
            sleep 2
            exit 1
        fi
    fi
}

func_local_repository () {
    # Found application path
    mkdir /tmp/update_dir >/dev/null 2>&1
    while read LINE
    do
        app_path=$LINE
    done < /tmp/update_path.txt
    rm -f /tmp/update_path.txt
    app_name=`basename $app_path`
    mv $app_path /tmp/update_dir
    if [ "$EDITION_NAME" = "Bedrock" ] && [[ "$app_name" = *".jar" ]]; then
        echo "The version to be updated does not match the existing edition"
        echo "Please select the appropriate new version edition"
        exit 1
    elif [ "$EDITION_NAME" = "Java" ] && [[ "$app_name" = "bedrock-server-"*".zip" ]]; then
        echo "The version to be updated does not match the existing edition"
        echo "Please select the appropriate new version edition"
        exit 1
    fi
    if [[ "$app_name" = *".jar" ]] && [[ "$app_name" != "minecraft_server."*".jar" ]]; then
        echo "--- Check Java application Version ---"
        echo "Enter the version of new minecraft server application"
        read -p "> " VERSION_NAME
        mv /tmp/update_dir/$app_name /tmp/update_dir/minecraft_server."$VERSION_NAME".jar
    elif [[ "$app_name" = "minecraft_server."*".jar" ]]; then
        VERSION_NAME=`echo $app_name | sed  -r "s/minecraft_server\.(.*)\.jar$/\1/"`
    elif [[ "$app_name" = "bedrock-server-"*".zip" ]]; then
        VERSION_NAME=`echo $app_name | sed -r "s/bedrock-server-(.*)\.zip$/\1/"`
    else
        echo "This file is not update file"
        echo "Please check it"
        rm -rf /tmp/update_dir
        sleep 2
        exit 1
    fi
    touch /tmp/tmp_version.txt
    echo $VERSION_NAME > /tmp/tmp_version.txt
}

func_update () {
    # Update application
    # Logging update time
    TIME=`date "+%Y%m%d_%H%M%S"`

    VERSION_NAME=`head -n 1 /tmp/tmp_version.txt`
    rm -f /tmp/tmp_version.txt

    # 1. Check container running
    online=`docker inspect --format='{{.State.Status}}' $CONTAINER_NAME`
    if [ $online != "running" ]; then
        echo "[SKIP] $CONTAINER_NAME is not running"
        echo "Please start the container before updating..."
        exit 1
    fi

    echo "--- Start update ---"

    # 2. Copy application to host
    if [ "$EDITION_NAME" = "Bedrock" ]; then
        online2=`docker exec $CONTAINER_NAME /bin/bash -c "ps ax | grep *bedrock_server | grep -v grep | wc -l"`
    else
        online2=`docker exec $CONTAINER_NAME /bin/bash -c "ps -ax | grep [j]ava | wc -l"`
    fi
    if [ $online2 -ge 1 ]; then
        echo "- Stop Minecraft server"
        docker exec -d $CONTAINER_NAME /usr/bin/tmux send-keys -t MCSV "say The Server stops after 10 seconds. Please SAVE immediately!" C-m
        sleep 10
        docker exec -d $CONTAINER_NAME /usr/bin/tmux send-keys -t MCSV "stop" C-m
        sleep 10
    fi
    echo "- Copy application to host"
    mkdir /tmp/old_minecraft_server_backup_$TIME
    if [ "$EDITION_NAME" = "Java" ]; then
        docker cp -q $CONTAINER_NAME:/opt/minecraft/java/. /tmp/old_minecraft_server_backup_$TIME/ 
        docker exec -d $CONTAINER_NAME /bin/bash -c "rm -rf /opt/minecraft/java/*"
    else
        docker cp -q $CONTAINER_NAME:/opt/minecraft/be/. /tmp/old_minecraft_server_backup_$TIME/
        docker exec -d $CONTAINER_NAME /bin/bash -c "rm -rf /opt/minecraft/be/*"
    fi

    # 4. Update files
    echo "- Update server"
    mkdir /tmp/update_dir/mcsv
    if [ "$EDITION_NAME" = "Java" ]; then
        cp -arT /tmp/old_minecraft_server_backup_$TIME/ /tmp/update_dir/mcsv/
        rm -f /tmp/update_dir/mcsv/*.jar
        cp /tmp/update_dir/minecraft_server."$VERSION_NAME".jar /tmp/update_dir/mcsv/
    else
        cp /tmp/update_dir/bedrock-server*.zip /tmp/update_dir/mcsv
        unzip /tmp/update_dir/mcsv/bedrock-server*.zip -d /tmp/update_dir/mcsv/ >/dev/null 2>&1
        
        echo "- Restore server data"
        rm -f /tmp/update_dir/mcsv/allowlist.json
        rm -f /tmp/update_dir/mcsv/permissions.json
        rm -f /tmp/update_dir/mcsv/server.properties

        cp /tmp/old_minecraft_server_backup_$TIME/allowlist.json /tmp/update_dir/mcsv/
        cp /tmp/old_minecraft_server_backup_$TIME/permissions.json /tmp/update_dir/mcsv/
        cp /tmp/old_minecraft_server_backup_$TIME/server.properties /tmp/update_dir/mcsv/
        cp -r /tmp/old_minecraft_server_backup_$TIME/worlds /tmp/update_dir/mcsv/
    fi

    # 5. Create application version infomation file
    echo "- Add version info"
    echo $VERSION_NAME > /tmp/update_dir/mcsv/version_info.txt
    sqlite3 /var/lib/mcsoc/mcsoc.sqlite3 <<END
    update container set VERSION = "$VERSION_NAME" where NAME = "$CONTAINER_NAME";
END

    # 6. Copy updated application to container
    echo "- Copy updated application to container"
    if [ "$EDITION_NAME" = "Java" ]; then
        docker cp -q /tmp/update_dir/mcsv/. $CONTAINER_NAME:/opt/minecraft/java/
    else
        docker cp -q /tmp/update_dir/mcsv/. $CONTAINER_NAME:/opt/minecraft/be/
    fi

    # 7. Delete update file
    echo "- Delete update file"
    rm -rf /tmp/update_dir

    # 8. Logging updated time
    echo "Updated application to $VERSION_NAME" > /var/log/mcsoc/$CONTAINER_NAME/app_update_$TIME.log
    echo "UPDATE TIME: $TIME" >> /var/log/mcsoc/$CONTAINER_NAME/app_update_$TIME.log

    # 9. Restart Minecraft server
    if [ $online2 -ge 1 ]; then
        echo "- Restart Minecraft server"
        if [ "$EDITION_NAME" = "Bedrock" ]; then
            docker exec -d $CONTAINER_NAME /usr/bin/tmux send-keys -t MCSV "LD_LIBRARY_PATH=. ./bedrock_server" C-m
        else
            MS_JAVA_MEM=`sqlite3 /var/lib/mcsoc/mcsoc.sqlite3<<END
            select MEMORY from container where NAME = "$CONTAINER_NAME";
END`
            docker exec -d $CONTAINER_NAME /usr/bin/tmux send-keys -t MCSV "java -Xmx${MS_JAVA_MEM} -Xms${MS_JAVA_MEM} -jar *.jar nogui" C-m
        fi
    fi

    echo "#################################"
    echo "      Update Completed !!"
    echo "#################################"
}

# Main
# Select Process
case $1 in
    -o ) func_online_download; func_update ;;
    -f ) func_local_repository; func_update ;;
esac