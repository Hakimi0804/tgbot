#!/bin/bash

## Sourcing stuffs (Our functions, extra functions ans aliases, etc)
source util.sh
source extra.sh

## While loop
while true; do
    # Refresh stuff
    update

    echo "$RET_MSG_TEXT"
    case $RET_MSG_TEXT in
        '/test'*)
            tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "BOT is running"
            ;;
        '.help'*)
            tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "No"
            ;;
        '.calc'*)
            TRIMMED="${RET_MSG_TEXT#.calc}"
            CALCED=$(echo "$TRIMMED" | bc -l 2>&1)
            #echo "$TRIMMED $CALCED"
            #od -c <<< "$CALCED"
            if ! echo "$CALCED" | grep -q 'syntax error'; then
                ROUNDED=$(round "$CALCED" 3)
                tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "$ROUNDED"
            else
                tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "bruh, did you just entered nonsense, cuz bc ain't happy"
            fi
            ;;
        '.fwdpost')
            PREV_POST=$(< "$HOME/.fwdpost_cooldown") || PREV_POST=$(( $(date +%s) - 11 ))
            if [ "$(( $(date +%s) - PREV_POST ))" -le 10 ]; then
                tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Wait for 10 secs cooldown plox"
                unset RET_MSG_TEXT
                continue
            fi
            if [[ " ${FWD_APRROVED_CHAT_ID[*]} " =~ " $RET_CHAT_ID " ]]; then
                tg --sendmsg "$RET_CHAT_ID" "Sending to @RM6785 ..."
                tg --cpmsg "$RET_CHAT_ID" "$FWD_TO" "$RET_REPLIED_MSG_ID"
                tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Post sent"
            else
                tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "You aren't allowed to use this command outside testing group"
            fi
            date +%s > "$HOME/.fwdpost_cooldown"
            ;;
        *[sS]ex*)
            tg --replysticker "$RET_CHAT_ID" "$RET_MSG_ID" "CAACAgUAAxkBAAED-qJiE3HljFCcMMJOY9e12JvDnvk7mAACCAgAAvNoIFQU9d93MQ1XZSME"
            ;;
        *t[ea]st[eu]r*mo[ra][er]*p*ro*than*dev*)
            tg --replysticker "$RET_CHAT_ID" "$RET_MSG_ID" "CAACAgQAAxkBAAED9_FiEMXeRur9aLMvyNnkj02cZew2ggACpAEAAsIupRbTkf08grqV_SME"
            ;;
    esac

    unset RET_MSG_TEXT
#    sleep .2
done
