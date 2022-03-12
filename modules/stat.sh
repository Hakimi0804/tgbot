#!/bin/bash

# When sourced:
[ -z "$SCRIPT_UPTIME_SET" ] && {
	readonly SCRIPT_BEGIN_RUN=$(date +%s)
	readonly SCRIPT_UPTIME_SET=true # Prevent begin time from being set twice (the readonly also helps)
}

stat() {
	# _LOADED_MODULES was modified in a subshell. That change might be lost.shellcheck(SC2031)
	# We will only use the variable here, so it's fine.
	# Modification of n is local (to subshell caused by (..) group).shellcheck(SC2030)
	# We will only use the variable here, so it's fine.
	# shhellcheck disable=SC2030,SC2031
	case "$RET_LOWERED_MSG_TEXT" in
	'.stat'*)
		(
			local SCRIPT_DIFF=$(($(date +%s) - SCRIPT_BEGIN_RUN))
			local n=$'\n'
			local _LOADED_MODULES
			for module in "${LOADED_MODULES[@]}"; do
				local _LOADED_MODULES="$_LOADED_MODULES${n}\`\\- ${module/\./\\\.}\`"
			done
			local STATUS="STATUS${n}loaded modules:$_LOADED_MODULES${n}script uptime: $((SCRIPT_DIFF / 3600)) hour\\(s\\) $(($((SCRIPT_DIFF / 60)) % 60)) min\\(s\\)"
			tg --replymarkdownv2msg "$RET_CHAT_ID" "$RET_MSG_ID" "$STATUS"
		) &
		;;
	'.modules'*)
		(
			local _LOADED_MODULES
			for module in "${LOADED_MODULES[@]}"; do
				local _LOADED_MODULES="$_LOADED_MODULES${n}\`\\- ${module/\./\\\.}\`"
			done
			tg --replymarkdownv2msg "$RET_CHAT_ID" "$RET_MSG_ID" "${_LOADED_MODULES}"
		) &
		;;
	esac
}
