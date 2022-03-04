#!/bin/bash

hakimi_afk() {
	case $RET_LOWERED_MSG_TEXT in
	*'@hakimi0804'*)
		if ! is_botowner; then err_not_botowner; return; fi
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "AFK MODULE LOADED: He is sleeping (Or perhaps he forgot to unload this module lol)"
		;;
	esac
}
