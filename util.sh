#!/bin/bash
source .token.sh

API="https://api.telegram.org/bot$TOKEN"

# Colours
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
reset='\033[0m'

exit_handler() {
	pr_warn "util" "Sigterm received"
	pr_warn "util" "Killing all jobs"
	for job in $(jobs -p); do
		kill "$job"
	done
	pr_warn "util" "Exiting"
	exit 0
}
trap 'exit_handler' EXIT
tg() {
	case $1 in
	--editmsg | --editmarkdownv2msg)
		local PARAM=$1
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local NEW_TEXT=$3
		if [[ $PARAM =~ "--editmarkdownv2msg" ]]; then
			curl -s "$API/editMessageText" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" -d "text=$NEW_TEXT" -d "parse_mode=MarkdownV2" | jq .
		else
			curl -s "$API/editMessageText" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" -d "text=$NEW_TEXT" | jq .
		fi
		;;
	--sendmsg)
		shift
		local CHAT_ID=$1
		local MSG=$2
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "text=$MSG")
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--sendmarkdownv2msg)
		shift
		local CHAT_ID=$1
		local MSG=$2
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "parse_mode=MarkdownV2" -d "text=$MSG")
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--replymsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "reply_to_message_id=$MSG_ID" -d "text=$MSG" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--replymarkdownv2msg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "reply_to_message_id=$MSG_ID" -d "text=$MSG" -d "parse_mode=MarkdownV2" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		echo "$RESULT"
		;;
	--delmsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		curl -s "$API/deleteMessage" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" | jq .
		;;
	--sendsticker | --replysticker)
		local PARAM=$1
		shift
		local CHAT_ID=$1
		local FILE_ID=$2
		if [[ $PARAM =~ "--replysticker" ]]; then
			local MSG_ID=$2
			local FILE_ID=$3
			curl "$API/sendSticker" -d "chat_id=$CHAT_ID" -d "sticker=$FILE_ID" -d "reply_to_message_id=$MSG_ID" | jq .
		else
			curl "$API/sendSticker" -d "chat_id=$CHAT_ID" -d "sticker=$FILE_ID" | jq .
		fi
		;;
	--fwdmsg | --cpmsg)
		local PARAM=$1 # Save this to check for --cpmsg
		shift
		local FROM=$1
		local TO=$2
		local MSG_ID=$3
		if [ "$PARAM" = "--cpmsg" ]; then
			local MODE=copyMessage
		else
			local MODE=forwardMessage
		fi
		curl "$API/$MODE" -d "from_chat_id=$FROM" -d "chat_id=$TO" -d "message_id=$MSG_ID"
		;;
	--pinmsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		curl "$API/pinChatMessage" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID"
		;;
	--unpinmsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		curl "$API/unpinChatMessage" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID"
		;;
	esac
}

update() {
	pr_debug "util" "Polling for updates... timeout: 60s"
	FETCH=$(curl -s "$API/getUpdates" -d "offset=$UPDATE_ID" -d "timeout=60" | jq '.result[]')
	if [ -n "$FETCH" ]; then
		UPDATE_ID=$((UPDATE_ID + 1))

		# IDs
		RET_MSG_ID=$(echo "$FETCH" | jq '.message.message_id')
		RET_CHAT_ID=$(echo "$FETCH" | jq '.message.chat.id')
		MSGGER=$(echo "$FETCH" | jq '.message.from.id')
		RET_FILE_ID=$(echo "$FETCH" | jq -r '.message.document.file_id')

		# Strings
		RET_MSG_TEXT=$(echo "$FETCH" | jq -r '.message.text')
		FIRST_NAME=$(echo "$FETCH" | jq -r '.message.first_name')
		USERNAME=$(echo "$FETCH" | jq -r '.message.username')

		# Replies
		RET_REPLIED_MSG_ID=$(echo "$FETCH" | jq '.message.reply_to_message.message_id')
		RET_REPLIED_MSGGER_ID=$(echo "$FETCH" | jq '.message.reply_to_message.from.id')
		RET_REPLIED_MSG_TEXT=$(echo "$FETCH" | jq -r '.message.reply_to_message.text')
		RET_REPLIED_FILE_ID=$(echo "$FETCH" | jq -r '.message.reply_to_message.document.file_id')

		# Stickers
		STICKER_EMOJI=$(echo "$FETCH" | jq -r '.message.sticker.emoji')
		STICKER_FILE_ID=$(echo "$FETCH" | jq -r '.message.sticker.file_id')
		STICKER_PACK_NAME=$(echo "$FETCH" | jq -r '.message.sticker.set_name')
	fi
}

update_init() {
	# Get initial update ID
	UPDATE_ID=$(curl -s "$API/getUpdates" -d "offset=-1" -d "timeout=60" | jq '.result[].update_id')
}

is_botowner() {
	[ "$MSGGER" = "$BOT_OWNER_ID" ] && return 0
	return 1
}

err_not_botowner() {
	tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "You are not allowed to use this command."
}

# Echo functions
# $1 = module name/main script
# $2 = text
pr_info() {
	echo -e "${green}I: $1\t: $2$reset"
}

pr_warn() {
	echo -e "${yellow}W: $1\t: $2$reset"
}

pr_error() {
	echo -e "${red}E: $1\t: $2$reset"
}

pr_debug() {
	echo -e "${purple}D: $1\t: $2$reset"
}
