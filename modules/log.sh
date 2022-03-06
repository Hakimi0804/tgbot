#!/bin/bash

log() {
	case $RET_LOWERED_MSG_TEXT in
	'.log'*)
		if ! is_botowner; then err_not_botowner; return; fi
		local _LOG_TYPE=${RET_MSG_TEXT#.log }
		rm -f "$HOME/logs/adb_logcat.txt"
		rm -f "$HOME/logs/adb_logcat_all.txt"
		rm -f "$HOME/logs/adb_logcat_radio.txt"
		kill "$_PREV_LOG_PID" 2>/dev/null
		(
			_log_for_five_sec "$_LOG_TYPE"
		) & # Do in background, subshell to avoid changes in in vars by other commands to affect this process
		_PREV_LOG_PID=$!
		;;
	esac
}

n=$'\n'

_log_editmsg() {
	tg --editmarkdownv2msg "$RET_CHAT_ID" "$SENT_MSG_ID" "${_LOG_PROGRESS[*]# }"
}

_log_date() {
	date +%H:%M:%S
}

_log_upload() {
	local _FILE_PATH=$1
	local _TMP_FILE_PATH_NAME=${_FILE_PATH/\./\\\.}
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- Uploading ${_TMP_FILE_PATH_NAME//_/\\_}$n"); _log_editmsg
	curl "$API/sendDocument" -F "chat_id=$RET_CHAT_ID" -F document=@"$_FILE_PATH"
	_log_link "$_FILE_PATH"
}

_log_for_five_sec() {
	local _TYPE=$1
	[ "$_TYPE" = ".log" ] && local _TYPE="normal"
	tg --replymarkdownv2msg "$RET_CHAT_ID" "$RET_MSG_ID" "Progress$n"
	_LOG_PROGRESS+=("Progress$n")
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- Waiting for device\\.\\.\\.$n"); _log_editmsg
	adb wait-for-device
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- Taking log \\| type: $_TYPE$n"); _log_editmsg
	case $_TYPE in
	'all')
		local _FILE_NAME="$HOME/logs/adb_logcat_all.txt"
		adb logcat -b all > "$HOME/logs/adb_logcat_all.txt" &
		;;
	'radio')
		local _FILE_NAME="$HOME/logs/adb_logcat_radio.txt"
		adb logcat -b radio > "$HOME/logs/adb_logcat_radio.txt" &
		;;
	*)
		local _FILE_NAME="$HOME/logs/adb_logcat.txt"
		adb logcat > "$HOME/logs/adb_logcat.txt" &
		;;
	esac
	sleep 5
	kill $!
	_log_purge "$_FILE_NAME"
}

_log_link() {
	local _FILE_PATH=$1
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- Generating termbin link$n"); _log_editmsg
	local _LOG_URL=$(nc termbin.com 9999 < "$_FILE_PATH")
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- termbin link: ${_LOG_URL/\./\\\.}$n"); _log_editmsg
	echo "DEBUG: ${_LOG_PROGRESS[*]}"
}

_log_purge() {
	local _FILE_PATH=$1
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- Purging AutoPasteSuggestionHelper \\(contains clipboard content\\)$n"); _log_editmsg
	sed -i '/AutoPasteSuggestionHelper/d' "$_FILE_PATH"
	_log_upload "$_FILE_PATH"
}
