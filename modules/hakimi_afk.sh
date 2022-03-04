#!/bin/bash

hakimi_afk() {
	case $RET_LOWERED_MSG_TEXT in
	*'@hakimi0804'*)
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "AFK MODULE LOADED: He is sleeping (Or perhaps he forgot to unload this module lol)"
		;;
	esac
}
