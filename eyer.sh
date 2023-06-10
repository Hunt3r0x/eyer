#!/bin/bash

CHECK_INTERVAL=5
LOG_FILE="logs.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

banner=$(cat << "EOF"

   ▄████████ ▄██   ▄      ▄████████    ▄████████    ▄████████ 
  ███    ███ ███   ██▄   ███    ███   ███    ███   ███    ███ 
  ███    █▀  ███▄▄▄███   ███    █▀    ███    █▀    ███    ███ 
 ▄███▄▄▄     ▀▀▀▀▀▀███  ▄███▄▄▄      ▄███▄▄▄      ▄███▄▄▄▄██▀ 
▀▀███▀▀▀     ▄██   ███ ▀▀███▀▀▀     ▀▀███▀▀▀     ▀▀███▀▀▀▀▀   
  ███    █▄  ███   ███   ███    █▄    ███    █▄  ▀███████████ 
  ███    ███ ███   ███   ███    ███   ███    ███   ███    ███ 
  ██████████  ▀█████▀    ██████████   ██████████   ███    ███ 
                                                   ███    ███     
                            by H1NTR0X01 @71ntr 
                            
EOF
)

echo -e "${BLUE}$banner${NC}"

FILES_TO_MONITOR=()

while getopts ":f:i:n:" opt; do
    case $opt in
        f)
            FILES_TO_MONITOR+=("$OPTARG")
            ;;
        i)
            CHECK_INTERVAL=$OPTARG
            ;;
        n)
            NOTIFICATION_ID=$OPTARG
            ;;
    esac
done

if [ ${#FILES_TO_MONITOR[@]} -eq 0 ]; then
    echo -e "${RED}Please specify file(s) to monitor with the -f flag.${NC}"
    exit 1
fi

if [ -z "$NOTIFICATION_ID" ]; then
    echo -e "${RED}Please specify a notification ID with the -n flag.${NC}"
    exit 1
fi

monitor_file_changes() {
    local file="$1"
    local last_modified=$(date -r "$file" +%s)
    
    while true; do
        local current_modified=$(date -r "$file" +%s)
        
        if [[ "$current_modified" != "$last_modified" ]]; then
            local current_time=$(date +"%Y-%m-%d %H:%M:%S")
            local user=$(whoami)
            
            echo -e "${GREEN}[$current_time] File $file has been modified by $user!${NC}"
            echo "[$current_time] $user made changes in $file" >> "$LOG_FILE"
            echo "- File $file has been modified! at [$current_time] " | notify -id $NOTIFICATION_ID > /dev/null 2>&1
            
            last_modified=$current_modified
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

# Wait for background processes to finish before exiting
wait
