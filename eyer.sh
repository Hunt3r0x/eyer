#!/bin/bash

CHECK_INTERVAL=5
LOG_FILE="logs.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

banner=$(
    cat <<"EOF"
 
   ▄████████ ▄██   ▄      ▄████████    ▄████████    ▄████████ 
  ███    ███ ███   ██▄   ███    ███   ███    ███   ███    ███ 
  ███    █▀  ███▄▄▄███   ███    █▀    ███    █▀    ███    ███ 
 ▄███▄▄▄     ▀▀▀▀▀▀███  ▄███▄▄▄      ▄███▄▄▄      ▄███▄▄▄▄██▀ 
▀▀███▀▀▀     ▄██   ███ ▀▀███▀▀▀     ▀▀███▀▀▀     ▀▀███▀▀▀▀▀   
  ███    █▄  ███   ███   ███    █▄    ███    █▄  ▀███████████ 
  ███    ███ ███   ███   ███    ███   ███    ███   ███    ███ 
  ██████████  ▀█████▀    ██████████   ██████████   ███    ███ 
                                                   ███    ███     
                            by H1NTR0X1 @71ntr 
                            
EOF
)

echo -e "${BLUE}$banner${NC}"

display_usage() {
    echo -e "${YELLOW}Usage:${NC} $0 ${GREEN}[-f <file1> [<file2> ...]] [-i <interval>] [-n <notification_id>] [-up <action>] [-filename <file_name>] [-h|--help]${NC}\n"
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  ${GREEN}-f <file1> [<file2> ...]:${NC} Specify file(s) to monitor"
    echo -e "  ${GREEN}-i <interval>:${NC} Specify the check interval in seconds (default: 5)"
    echo -e "  ${GREEN}-n <notification_id>:${NC} Specify the notification ID"
    echo -e "  ${GREEN}-up <action>:${NC} Specify the action to send the file when a file is updated"
    echo -e "  ${GREEN}-filename <file_name>:${NC} Specify the name of the file"
    echo -e "  ${GREEN}-h, --help:${NC} Display this help message and exit"
    echo -e ""
}

if [[ $# -eq 0 ]]; then
    display_usage
    exit 1
fi

FILES_TO_MONITOR=()
UP_ACTION=""

while [ -n "$1" ]; do
    case $1 in
    -f)
        shift
        FILES_TO_MONITOR+=("$1")
        ;;
    -i)
        shift
        CHECK_INTERVAL=$1
        ;;
    -n)
        shift
        NOTIFICATION_ID=$1
        ;;
    -up)
        shift
        UP_ACTION=$1
        ;;
    -filename)
        shift
        FILE_NAME=$1
        ;;
    esac
    shift
done

get_webhook_url() {
    local id="$1"
    local file="$HOME/.config/notify/provider-config.yaml"
    local url=$(grep -A 4 "id: \"$id\"" "$file" | grep 'discord_webhook_url' | cut -d '"' -f 2)
    if [ -z "$url" ]; then
        echo "Error: ID '$id' not found or no webhook URL found for the ID '$id'." >&2
        return 1
    else
        echo "$url"
    fi
}

if [ ${#FILES_TO_MONITOR[@]} -eq 0 ]; then
    echo -e "${RED}Please specify file(s) to monitor with the -f flag.${NC}"
    exit 1
fi

if [ -z "$NOTIFICATION_ID" ]; then
    echo -e "${RED}Please specify a notification ID with the -n flag.${NC}"
    exit 1
fi

notifyz() {
    WEBHOOK_URL=$(get_webhook_url "$NOTIFICATION_ID")
    message_up="
### Hey, Bro!
UPDATED SUBDOAMINS FILE FOR => **${FILE_NAME}**
LAST MODIFIED => **${current_time}**
"
    response=$(curl -s -q -X POST \
        -H "Content-Type: multipart/form-data" \
        -F "file=@$file;filename=${FILE_NAME}.txt" \
        -F "content=${message_up}" \
        "$WEBHOOK_URL")
}

notify_user() {
    local message="$1"
    local notification_id="$2"
    echo "$message" | notify -silent -id "$notification_id" >/dev/null 2>&1
}

monitor_file_changes() {
    local file="$1"
    local last_modified=$(date -r "$file" +%s)
    local deleted=false

    while true; do
        if [ ! -f "$file" ]; then
            if [ "$deleted" = false ]; then
                local current_time=$(date +"%Y-%m-%d %H:%M:%S")
                local user=$(whoami)

                echo -e "${YELLOW}[$current_time] File $file has been deleted by $user!${NC}"
                echo "[$current_time] $user deleted $file" >>"$LOG_FILE"
                notify_user "- File $file has been deleted! at [$current_time] " "$NOTIFICATION_ID"
                deleted=true
            fi
        else
            deleted=false
            local current_modified=$(date -r "$file" +%s)

            if [[ "$current_modified" != "$last_modified" ]]; then
                local current_time=$(date +"%Y-%m-%d %H:%M:%S")
                local user=$(whoami)

                echo -e "${GREEN}[$current_time] File $file has been modified by $user!${NC}"
                echo "[$current_time] $user made changes in $file" >>"$LOG_FILE"

                if [ -n "$UP_ACTION" ]; then
                    notifyz
                fi
                last_modified=$current_modified
            fi
        fi
        sleep "$CHECK_INTERVAL"
    done
}

for file in "${FILES_TO_MONITOR[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}File '$file' does not exist.${NC}"
        exit 1
    fi

    monitor_file_changes "$file" &
done

wait
