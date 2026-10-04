#!/bin/bash

########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2026 kokoroq. All rights reserved.
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

DB="/var/lib/mcsoc/mcsoc.sqlite3"
NEW_DIR="/tmp/new_server"

# Set container name
if [ ! -s /tmp/container_name.txt ]; then
    echo "[ERROR] /tmp/container_name.txt not found"
    exit 1
fi
CONTAINER_NAME=$(head -n 1 /tmp/container_name.txt)
rm -f /tmp/container_name.txt
# Escape single quotes for SQL
SQL_NAME=${CONTAINER_NAME//\'/\'\'}

# Set edition
EDITION_NAME=$(sqlite3 "$DB" "select EDITION from container where NAME = '$SQL_NAME';")
if [ "$EDITION_NAME" != "Bedrock" ] && [ "$EDITION_NAME" != "Java" ]; then
    echo "[ERROR] Unknown edition for container: $CONTAINER_NAME"
    exit 1
fi

if [ "$EDITION_NAME" = "Java" ]; then
    APP_DIR="/opt/minecraft/java"
else
    APP_DIR="/opt/minecraft/be"
fi

# Always remove the temporary application dir on exit (success or failure)
trap 'rm -rf "$NEW_DIR"' EXIT

#####################

#     Helpers       #

# Number of running server processes inside the container
count_server_procs () {
    local n
    if [ "$EDITION_NAME" = "Bedrock" ]; then
        n=$(docker exec "$CONTAINER_NAME" /bin/bash -c "ps ax | grep '[b]edrock_server' | wc -l")
    else
        n=$(docker exec "$CONTAINER_NAME" /bin/bash -c "ps ax | grep '[j]ava' | wc -l")
    fi
    echo "${n:-0}"
}

start_server () {
    if [ "$EDITION_NAME" = "Bedrock" ]; then
        docker exec "$CONTAINER_NAME" /usr/bin/tmux send-keys -t MCSV "cd $APP_DIR && LD_LIBRARY_PATH=. ./bedrock_server" C-m
    else
        MS_JAVA_MEM=$(sqlite3 "$DB" "select MEMORY from container where NAME = '$SQL_NAME';")
        docker exec "$CONTAINER_NAME" /usr/bin/tmux send-keys -t MCSV "cd $APP_DIR && java -Xmx${MS_JAVA_MEM} -Xms${MS_JAVA_MEM} -jar *.jar nogui" C-m
    fi
}

# Abort the update. Restart the (still untouched) old server if it was running.
abort_update () {
    echo "[ERROR] $1"
    echo "Update aborted."
    if [ "${online2:-0}" -ge 1 ]; then
        echo "- Restart Minecraft server"
        start_server
    fi
    exit 1
}

check_version () {
    if [[ ! "$1" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo "[ERROR] Invalid version string: '$1'"
        exit 1
    fi
}

download_failed () {
    echo "Download failed..."
    echo "Stop update"
    sleep 2
    exit 1
}

#####################

# Function for start
func_online_download () {
    # BE or JAVA
    echo "Download application from Internet"
    rm -rf "$NEW_DIR"
    mkdir -p "$NEW_DIR"
    if [ "$EDITION_NAME" = "Bedrock" ]; then
        # Download process
        read -rp "Enter the 'URL' of the Minecraft Bedrock server application > " be_url
        echo "Now Downloading..."
        # minecraft.net rejects wget's default User-Agent (HTTP 403)
        wget -v -P "$NEW_DIR" --user-agent="Mozilla/5.0" "$be_url"
        app_file=$(ls "$NEW_DIR"/bedrock-server-*.zip 2>/dev/null | head -n 1)
        if [ -n "$app_file" ]; then
            echo "Download successfully!"
            app_name=$(basename "$app_file")
            VERSION_NAME=$(echo "$app_name" | sed -r "s/bedrock-server-(.*)\.zip$/\1/")
        else
            download_failed
        fi
    else
        # Download process
        read -rp "Enter the version to download new minecraft server application > " VERSION_NAME
        check_version "$VERSION_NAME"
        echo
        read -rp "Enter the 'URL' of the Minecraft Java server application > " java_url
        echo "Now Downloading..."
        wget -v -O "$NEW_DIR/server.jar" "$java_url"
        if [ -s "$NEW_DIR/server.jar" ]; then
            echo "Download successfully!"
            mv "$NEW_DIR/server.jar" "$NEW_DIR/minecraft_server.$VERSION_NAME.jar"
        else
            download_failed
        fi
    fi
    check_version "$VERSION_NAME"
}

func_local_repository () {
    # Found application path
    rm -rf "$NEW_DIR"
    mkdir -p "$NEW_DIR"
    if [ ! -s /tmp/update_path.txt ]; then
        echo "[ERROR] /tmp/update_path.txt not found"
        exit 1
    fi
    app_path=$(head -n 1 /tmp/update_path.txt)
    rm -f /tmp/update_path.txt
    if [ ! -f "$app_path" ]; then
        echo "[ERROR] File not found: $app_path"
        exit 1
    fi
    app_name=$(basename "$app_path")

    # Check edition BEFORE touching the file
    if [ "$EDITION_NAME" = "Bedrock" ] && [[ "$app_name" = *".jar" ]]; then
        echo "The version to be updated does not match the existing edition"
        echo "Please select the appropriate new version edition"
        exit 1
    elif [ "$EDITION_NAME" = "Java" ] && [[ "$app_name" = "bedrock-server-"*".zip" ]]; then
        echo "The version to be updated does not match the existing edition"
        echo "Please select the appropriate new version edition"
        exit 1
    fi

    # NOTE: copy (not move) so the user's original file is never lost
    if [[ "$app_name" = *".jar" ]] && [[ "$app_name" != "minecraft_server."*".jar" ]]; then
        echo "--- Check Java application Version ---"
        read -rp "Enter the version of new minecraft server application > " VERSION_NAME
        check_version "$VERSION_NAME"
        cp "$app_path" "$NEW_DIR/minecraft_server.$VERSION_NAME.jar" || exit 1
    elif [[ "$app_name" = "minecraft_server."*".jar" ]]; then
        VERSION_NAME=$(echo "$app_name" | sed -r "s/minecraft_server\.(.*)\.jar$/\1/")
        cp "$app_path" "$NEW_DIR/$app_name" || exit 1
    elif [[ "$app_name" = "bedrock-server-"*".zip" ]]; then
        VERSION_NAME=$(echo "$app_name" | sed -r "s/bedrock-server-(.*)\.zip$/\1/")
        cp "$app_path" "$NEW_DIR/$app_name" || exit 1
    else
        echo "This file is not update file"
        echo "Please check it"
        sleep 2
        exit 1
    fi
    check_version "$VERSION_NAME"
}

func_update () {
    # Update application
    # Logging update time
    TIME=$(date "+%Y%m%d_%H%M%S")
    BACKUP_DIR="$HOME/old_minecraft_server_backup_$TIME"
    WORK_DIR="$HOME/update_dir/mcsv"

    # (VERSION_NAME is inherited from func_online_download / func_local_repository)
    if [ -z "$VERSION_NAME" ]; then
        echo "[ERROR] VERSION_NAME is empty"
        exit 1
    fi

    # 1. Check container running
    online=$(docker inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)
    if [ "$online" != "running" ]; then
        echo "[SKIP] $CONTAINER_NAME is not running"
        echo "Please start the container before updating..."
        exit 1
    fi

    echo "--- Start update ---"

    # 2. Stop server (if running) and wait until it has really stopped
    online2=$(count_server_procs)
    if [ "$online2" -ge 1 ]; then
        echo "- Stop Minecraft server"
        docker exec "$CONTAINER_NAME" /usr/bin/tmux send-keys -t MCSV "say The Server stops after 10 seconds. Please SAVE immediately!" C-m
        sleep 10
        docker exec "$CONTAINER_NAME" /usr/bin/tmux send-keys -t MCSV "stop" C-m
        for _ in $(seq 1 30); do
            [ "$(count_server_procs)" -eq 0 ] && break
            sleep 2
        done
        if [ "$(count_server_procs)" -ne 0 ]; then
            echo "[ERROR] Minecraft server did not stop. Update aborted (nothing was changed)."
            exit 1
        fi
    fi

    # 3. Copy application to host (backup)
    echo "- Copy application to host"
    mkdir -p "$BACKUP_DIR"
    if ! docker cp -q "$CONTAINER_NAME:$APP_DIR/." "$BACKUP_DIR/" || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        abort_update "Backup failed (nothing was deleted)"
    fi

    # 4. Build the new application on the host
    echo "- Update server"
    rm -rf "$HOME/update_dir"
    mkdir -p "$WORK_DIR"
    if [ "$EDITION_NAME" = "Java" ]; then
        cp -arT "$BACKUP_DIR/" "$WORK_DIR/" || abort_update "Failed to copy backup"
        rm -f "$WORK_DIR"/*.jar
        cp "$NEW_DIR/minecraft_server.$VERSION_NAME.jar" "$WORK_DIR/" || abort_update "New jar not found"
    else
        unzip -o -q "$NEW_DIR/bedrock-server-$VERSION_NAME.zip" -d "$WORK_DIR" || abort_update "Failed to unzip new server"

        echo "- Restore server data"
        for f in allowlist.json permissions.json server.properties; do
            if [ -f "$BACKUP_DIR/$f" ]; then
                cp -f "$BACKUP_DIR/$f" "$WORK_DIR/$f" || abort_update "Failed to restore $f"
            else
                echo "[WARN] $f was not found in the old server. Using the default one."
            fi
        done
        if [ -d "$BACKUP_DIR/worlds" ]; then
            rm -rf "$WORK_DIR/worlds"
            cp -a "$BACKUP_DIR/worlds" "$WORK_DIR/" || abort_update "Failed to restore worlds"
        else
            echo "[WARN] worlds directory was not found in the old server."
        fi

        # Restore custom packs (merge).
        # Packs bundled with the new server (vanilla) are kept as the NEW version;
        # only packs that do not exist in the new server are copied from the backup.
        for packs in behavior_packs resource_packs; do
            [ -d "$BACKUP_DIR/$packs" ] || continue
            mkdir -p "$WORK_DIR/$packs"
            for pack in "$BACKUP_DIR/$packs"/*; do
                [ -e "$pack" ] || continue
                pack_name=$(basename "$pack")
                if [ ! -e "$WORK_DIR/$packs/$pack_name" ]; then
                    cp -a "$pack" "$WORK_DIR/$packs/" || abort_update "Failed to restore $packs/$pack_name"
                    echo "  restored: $packs/$pack_name"
                fi
            done
        done
    fi

    # 5. Create application version information file
    echo "- Add version info"
    echo "$VERSION_NAME" > "$WORK_DIR/version_info.txt"

    # 6. Replace application in the container (roll back on failure)
    echo "- Copy updated application to container"
    docker exec "$CONTAINER_NAME" /bin/bash -c "rm -rf ${APP_DIR:?}/*"
    if ! docker cp -q "$WORK_DIR/." "$CONTAINER_NAME:$APP_DIR/"; then
        echo "[ERROR] Failed to copy the new application. Rolling back..."
        docker exec "$CONTAINER_NAME" /bin/bash -c "rm -rf ${APP_DIR:?}/*"
        docker cp -q "$BACKUP_DIR/." "$CONTAINER_NAME:$APP_DIR/"
        abort_update "Rolled back to the previous version (backup: $BACKUP_DIR)"
    fi

    # 7. Record new version in DB (only after everything succeeded)
    sqlite3 "$DB" "update container set VERSION = '$VERSION_NAME' where NAME = '$SQL_NAME';"

    # 8. Delete update files
    echo "- Delete update file"
    rm -rf "$NEW_DIR"
    rm -rf "$HOME/update_dir"

    # 9. Logging updated time
    LOG_DIR="/var/log/mcsoc/$CONTAINER_NAME"
    mkdir -p "$LOG_DIR"
    {
        echo "Updated application to $VERSION_NAME"
        echo "UPDATE TIME: $TIME"
    } > "$LOG_DIR/app_update_$TIME.log"

    # 10. Restart Minecraft server
    if [ "$online2" -ge 1 ]; then
        echo "- Restart Minecraft server"
        start_server
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
    *  ) echo "Usage: $0 {-o|-f}"; exit 1 ;;
esac