#!/bin/bash

hakimi_afk() {
	case $RET_LOWERED_MSG_TEXT in
	*'@hakimi0804'*)
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "AFK MODULE LOADED: He is sleeping/AFK (Or perhaps he forgot to unload this module lol)"
		;;
	*)
		if [ "$RET_REPLIED_MSGGER_ID" = "$BOT_OWNER_ID" ]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "AFK MODULE LOADED: He is sleeping/AFK (Or perhaps he forgot to unload this module lol)"
			unset RET_REPLIED_MSGGER_ID
		fi
		;;
	esac
}
