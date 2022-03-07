#!/bin/bash

realme_ofp() {
	case $RET_LOWERED_MSG_TEXT in
	'.ofp'*)
		echo "DEBUG: ofp triggered"
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Please wait..."
		_realme_ofp_handler ${RET_MSG_TEXT#.ofp } || {
			tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Invalid device"
			return
		}
		[ -z "$_REALME_OFP_LINK" ] && {
			tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Function returned empty var. Version/region not available or invalid device?"
			return
		}
		_realme_ofp_editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "$_REALME_OFP_LINK"
		unset _REALME_OFP_LINK
		echo "DEBUG: Done processing ofp"
		;;
	esac
}

_realme_ofp_handler() {
	export PATH=$HOME/.local/bin:$PATH
	if [ "$(wc -c <<< "$1")" -ne 8 ]; then
		rm *.csv
		rm *.*xlsx
		return 1
	fi
	gdown "$OFP_SHEET" # This var refers to a secret in .token.sh
	xlsx2csv Software update summary form新版软件汇总表.xlsx > ofp.csv
	touch temp.txt
	grep "${1}.*${2}" ofp.csv | grep ".${3}." | egrep -o "(http|https)://[a-zA-Z0-9./?=_%:-]*" >temp.txt
	sed -i "s/\n/\n\n/" temp.txt
	_REALME_OFP_LINK=$(cat temp.txt)
	rm *.csv
	rm *.*xlsx
	rm temp.txt
	echo "DEBUG: function return 0"
	return 0
}

_realme_ofp_editmsg() {
	local CHAT_ID=$1
	local MSG_ID=$2
	local TEXT=$3
	echo "DEBUG: editing"
	curl -s "$API/editMessageText" -F "chat_id=$CHAT_ID" -F "message_id=$MSG_ID" -F "text=$TEXT" | jq .
}
