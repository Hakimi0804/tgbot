#!/bin/bash

# When sourced:
[ -z "$SCRIPT_UPTIME_SET" ] && {
	readonly SCRIPT_BEGIN_RUN=$(date +%s)
	readonly SCRIPT_UPTIME_SET=true # Prevent begin time from being set twice (the readonly also helps)
}

stat() {
	case "$RET_LOWERED_MSG_TEXT" in
	'.stat'*)
		local SCRIPT_DIFF=$(($(date +%s) - SCRIPT_BEGIN_RUN))
		local n=$'\n'
		local _LOADED_MODULES
		for module in "${LOADED_MODULES[@]}"; do
			_LOADED_MODULES="$_LOADED_MODULES${n}\`\\- ${module/\./\\\.}\`"
		done
		local STATUS="STATUS${n}loaded modules:$_LOADED_MODULES${n}script uptime: $((SCRIPT_DIFF / 3600)) hour\\(s\\) $(($((SCRIPT_DIFF / 60)) % 60)) min\\(s\\)"
		tg --replymarkdownv2msg "$RET_CHAT_ID" "$RET_MSG_ID" "$STATUS"
		;;
	'.modules'*)
		local _LOADED_MODULES
		for module in "${LOADED_MODULES[@]}"; do
			_LOADED_MODULES="$_LOADED_MODULES${n}\`\\- ${module/\./\\\.}\`"
		done
		tg --replymarkdownv2msg "$RET_CHAT_ID" "$RET_MSG_ID" "${_LOADED_MODULES}"
		;;
	esac
}
