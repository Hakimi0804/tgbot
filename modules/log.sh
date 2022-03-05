#!/bin/bash

log() {
	case $RET_LOWERED_MSG_TEXT in
	'.log'*)
		if ! is_botowner; then err_not_botowner; return; fi
		local _LOG_TYPE=${RET_MSG_TEXT#.log }
		rm -f "$HOME/logs/adb_logcat.txt"
		rm -f "$HOME/logs/adb_logcat_all.txt"
		rm -f "$HOME/logs/adb_logcat_radio.txt"
		(
			_log_for_five_sec "$_LOG_TYPE"
		) &
		;;
	esac
}

_log_upload() {
	local _FILE_PATH=$1
	tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Uploading $_FILE_PATH"
	curl "$API/sendDocument" -F "chat_id=$RET_CHAT_ID" -F document=@"$_FILE_PATH"
}

_log_for_five_sec() {
	local _TYPE=$1
	tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Waiting for device"
	adb wait-for-device
	case $TYPE in
	'all')
		tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Taking logs
log type: -b all"
		local _FILE_NAME="$HOME/logs/adb_logcat_all.txt"
		adb logcat -b all > "$HOME/logs/adb_logcat_all.txt" &
		;;
	'radio')
		tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Taking logs
log type: -b radio"
		local _FILE_NAME="$HOME/logs/adb_logcat_radio.txt"
		adb logcat -b radio > "$HOME/logs/adb_logcat_radio.txt" &
		;;
	*)
		tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Taking logs
log type: normal"
		local _FILE_NAME="$HOME/logs/adb_logcat.txt"
		adb logcat > "$HOME/logs/adb_logcat.txt" &
		;;
	esac
	sleep 5
	kill $!
	_log_upload "$_FILE_NAME"
}
