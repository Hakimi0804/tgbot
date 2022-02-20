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
        --sendmarkdownv2msg)
            shift
            local CHAT_ID=$1
            local MSG=$2
            local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "parse_mode=MarkdownV2" -d "text=$MSG")
            SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
            ;;
        --replymsg)
            shift
            local CHAT_ID=$1
            local MSG_ID=$2
            local MSG=$3
            curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "reply_to_message_id=$MSG_ID" -d "text=$MSG" | jq .
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
        --fwdmsg | --cpmsg)
            local PARAM=$1 # Save this to check for --cpmsg
            shift
            local FROM=$1
            local TO=$2
            local MSG_ID=$3
            if [ "$PARAM" = "--cpmsg" ]; then
                local MODE=copyMessage
            else
                local MODE=forwardMessage
            fi
            curl "$API/$MODE" -d "from_chat_id=$FROM" -d "chat_id=$TO" -d "message_id=$MSG_ID"
            ;;
    esac
}

update() {
    FETCH=$(curl -s "$API/getUpdates" -d "offset=-1" -d "timeout=60" | jq '.result[]')
    UPDATE_ID=$(echo "$FETCH" | jq '.update_id')
    [ -z "$PREV_UPDATE_ID" ] && PREV_UPDATE_ID=$UPDATE_ID

    if [ $UPDATE_ID -gt $PREV_UPDATE_ID ]; then
        # IDs
        PREV_UPDATE_ID=$UPDATE_ID
        RET_MSG_ID=$(echo "$FETCH" | jq '.message | .message_id')
        RET_CHAT_ID=$(echo "$FETCH" | jq '.message | .chat | .id')
        MSGGER=$(echo "$FETCH" | jq '.message | .from | .id')

        # Strings
        RET_MSG_TEXT=$(echo "$FETCH" | jq -r '.message | .text')
        FIRST_NAME=$(echo "$FETCH" | jq -r '.message | .first_name')
        USERNAME=$(echo "$FETCH" | jq -r '.message | .username')

        # Replies
        RET_REPLIED_MSG_ID=$(echo "$FETCH" | jq '.message | .reply_to_message | .message_id')
        RET_REPLIED_MSG_CHAT_ID=$(echo "$FETCH" | jq '.message | .reply_to_message | .from | .id')

        # Stickers
        STICKER_EMOJI=$(echo "$FETCH" | jq -r '.message | .sticker | .emoji')
        STICKER_FILE_ID=$(echo "$FETCH" | jq '.message | .sticker | .file_id')
        STICKER_PACK_NAME=$(echo "$FETCH" | jq '.message | .sticker | .set_name')
    fi
}
