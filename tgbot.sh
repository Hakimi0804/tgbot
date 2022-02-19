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
            tg --sendmsg "$RET_CHAT_ID" "BOT is running"
            ;;
        '.help'*)
            tg --sendmsg "$RET_CHAT_ID" "No"
            ;;
        '.calc'*)
            TRIMMED="${RET_MSG_TEXT#.calc}"
            CALCED=$(echo "$TRIMMED" | bc -l 2>&1)
            #echo "$TRIMMED $CALCED"
            #od -c <<< "$CALCED"
            if ! echo "$CALCED" | grep -q 'syntax error'; then
                ROUNDED=$(round "$CALCED" 3)
                tg --sendmsg "$RET_CHAT_ID" "$ROUNDED"
            else
                tg --sendmsg "$RET_CHAT_ID" "bruh, did you just entered nonsense, cuz bc ain't happy"
            fi
            ;;
        t[ea]st[eu]r*mo[ra][er]*p*ro*than*dev)
            tg --sendsticker "$RET_CHAT_ID" "CAACAgQAAxkBAAED9_FiEMXeRur9aLMvyNnkj02cZew2ggACpAEAAsIupRbTkf08grqV_SME"
            ;;
    esac

    unset RET_MSG_TEXT
#    sleep .2
done
