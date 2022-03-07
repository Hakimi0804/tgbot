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
		local _LOADED_MODULES
		for module in "${LOADED_MODULES[@]}"; do
			_LOADED_MODULES="$_LOADED_MODULES${n}\`\\- ${module/\./\\\.}\`"
		done
		echo "$_LOADED_MODULES"
		tg --editmarkdownv2msg "$RET_CHAT_ID" "$SENT_MSG_ID" "Modules reloaded, loaded modules:${_LOADED_MODULES//_/\\_}"
		;;
	esac
}

# For use from other modules without sending message
restart_nomessage() {
	exec ./tgbot.sh
}
