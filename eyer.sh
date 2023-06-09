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

while getopts ":f:i:n:" opt; do
    case $opt in
        f)
            FILE_TO_MONITOR=$OPTARG
            ;;
        i)
            CHECK_INTERVAL=$OPTARG
            ;;
        n)
            NOTIFICATION_ID=$OPTARG
            ;;
    esac
done

if [ -z "$FILE_TO_MONITOR" ]; then
    echo -e "${RED}Please specify a file to monitor with the -f flag.${NC}"
    exit 1
fi

if [ -z "$NOTIFICATION_ID" ]; then
    echo -e "${RED}Please specify a notification ID with the -n flag.${NC}"
    exit 1
fi

if [ ! -f "$FILE_TO_MONITOR" ]; then
    echo -e "${RED}File '$FILE_TO_MONITOR' does not exist.${NC}"
    exit 1
fi

LAST_MODIFIED=$(stat -c %Y "$FILE_TO_MONITOR")

while true; do
    if [ ! -f "$FILE_TO_MONITOR" ]; then
        echo -e "${RED}File '$FILE_TO_MONITOR' no longer exists.${NC}"
        exit 1
    fi

    CURRENT_MODIFIED=$(stat -c %Y "$FILE_TO_MONITOR")

    if [[ "$CURRENT_MODIFIED" != "$LAST_MODIFIED" ]]; then
        CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
        USER=$(whoami)
        echo -e "${GREEN}[$CURRENT_TIME] File $FILE_TO_MONITOR has been modified by $USER!${NC}"
        echo "[$CURRENT_TIME] $USER made changes in $FILE_TO_MONITOR" >> "$LOG_FILE"
        echo "- File $FILE_TO_MONITOR has been modified! at [$CURRENT_TIME] " | notify -id $NOTIFICATION_ID > /dev/null 2>&1
        LAST_MODIFIED=$CURRENT_MODIFIED
    fi

    sleep "$CHECK_INTERVAL"
done
