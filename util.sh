#!/bin/bash
source .token.sh

API="https://api.telegram.org/bot$TOKEN"
tg() {
    case $1 in
        --editmsg)
            shift
            local CHAT_ID=$1
            local MSG_ID=$2
            local NEW_TEXT=$3
            curl -s "$API/editMessageText" -d "chat_id=$CHAT_ID" -d "message_id=$MESSAGE_ID" "text=$NEW_TEXT" | jq .
            ;;
        --sendmsg)
            shift
            local CHAT_ID=$1
            local MSG=$2
            local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "text=$MSG")
            SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
            ;;
        --delmsg)
            shift
            local CHAT_ID=$1
            local MSG_ID=$2
            curl -s "$API/deleteMessage" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" | jq .
            ;;
        --sendsticker)
            shift
            local CHAT_ID=$1
            local FILE_ID=$2
            curl "$API/sendSticker" -d "chat_id=$CHAT_ID" -d "sticker=$FILE_ID" | jq .
            ;;
    esac
}

update() {
    alias echo='echo -n'
    FETCH=$(curl -s "$API/getUpdates" | jq '.result[]')
    if [ -n "$FETCH" ]; then
        MSGGER=$(echo "$FETCH" | jq '.message | .from | .id')
        RET_MSG_ID=$(echo "$FETCH" | jq '.message | .message_id')
        RET_MSG_TEXT=$(echo "$FETCH" | jq '.message | .text')
        RET_CHAT_ID=$(echo "$FETCH" | jq '.message | .chat | .id')
        FIRST_NAME=$(echo "$FETCH" | jq '.message | .first_name')
        USERNAME=$(echo "$FETCH" | jq '.message | .username')
    fi
    unalias echo
}

clear_update() { unset FETCH MSGGER RET_MSG_ID RET_MSG_TEXT RET_CHAT_ID FIRST_NAME USERNAME; }
