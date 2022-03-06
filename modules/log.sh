#!/bin/bash

log() {
	_scrub_gist
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

_log_editmsg_editor() {
	local CHAT_ID=$1
	local MSG_ID=$2
	local TEXT=$3
	curl -s "$API/editMessageText" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" -d "text=$TEXT" -d "parse_mode=markdownv2" -d "disable_web_page_preview=true"
}

_log_editmsg() {
	_log_editmsg_editor "$RET_CHAT_ID" "$SENT_MSG_ID" "${_LOG_PROGRESS[*]# }"
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
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- Creating gist$n"); _log_editmsg
	local _LOG_URL=$(gh gist create < "$_FILE_PATH" | tail -n1)
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- gist link: ${_LOG_URL//\./\\\.}$n"); _log_editmsg
	echo "$_LOG_URL" >> ~/.gist_markers # Once lines exceed 30, we need to delete old gist
}

_log_purge() {
	local _FILE_PATH=$1
	_LOG_PROGRESS+=("\`$(_log_date)\` \\- Purging AutoPasteSuggestionHelper \\(contains clipboard content\\)$n"); _log_editmsg
	sed -i '/AutoPasteSuggestionHelper/d' "$_FILE_PATH"
	_log_upload "$_FILE_PATH"
}

_scrub_gist() {
	# Count lines of ~/.gist_markers
	local _GIST_COUNT=$(wc -l < ~/.gist_markers)
	# If lines exceed 30, delete oldest gist
	if [ "$_GIST_COUNT" -gt 30 ]; then
		local _OLDEST_GIST=$(head -n1 ~/.gist_markers)
		gh gist delete "$_OLDEST_GIST"
		sed -i '1d' ~/.gist_markers
	fi
}
