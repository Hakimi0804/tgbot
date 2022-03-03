#!/bin/bash

uptime() {
	case $RET_LOWERED_MSG_TEXT in
    '.uptime'*)
    	UPTIME_OUTPUT=$(command uptime -p)
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Uptime: $UPTIME_OUTPUT"
        true
		;;
	esac
}
