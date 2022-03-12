#!/bin/bash

rm6785_post() {
	case $RET_LOWERED_MSG_TEXT in
	'.sticker'*)
		(
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Hold on..."
			tg --sendsticker "$FWD_TO" "$RM6785_UPDATE_STICKER"
			tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Sticker sent"
		) &
		;;
	'.post'*)
		(
			if [ "$RET_REPLIED_MSG_ID" = "null" ]; then
				tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Reply to a message plox"
			else
				if [[ " ${FWD_APRROVED_CHAT_ID[*]} " =~ " $RET_CHAT_ID " ]]; then
					tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Hold on..."
					tg --cpmsg "$RET_CHAT_ID" "$FWD_TO" "$RET_REPLIED_MSG_ID"
					tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Posted"
				else
					tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "You can only use this command in testing group"
				fi
			fi
		) &
		;;
	esac
}
