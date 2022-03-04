#!/bin/bash

[[ "$SCRIPT_RESTARTED" == true ]] && {
	tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Back running"
	unset SCRIPT_RESTARTED
}

restart() {
	local n=$'\n'
	case $RET_LOWERED_MSG_TEXT in
	'.restart')
		if ! is_botowner; then err_not_botowner; return; fi
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Restarting"
		export SENT_MSG_ID
		export RET_CHAT_ID
		export SCRIPT_RESTARTED=true
		exec ./tgbot.sh
		;;
	'.reload')
		if ! is_botowner; then err_not_botowner; return; fi
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Reloading modules"
		load_modules
		tg --editmarkdownv2msg "$RET_CHAT_ID" "$SENT_MSG_ID" "Modules reloaded, loaded modules:${n}${n}\`${LOADED_MODULES[*]}\`"
		;;
	esac
}

# For use from other modules without sending message
restart_nomessage() {
	exec ./tgbot.sh
}
