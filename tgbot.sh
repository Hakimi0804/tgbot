#!/bin/bash

clear

## Sourcing stuffs (Our functions, extra functions ans aliases, etc)
source util.sh
source extra.sh
source modules_loader.sh

## While loop
while true; do
	# Refresh stuff
	update
	[ "$RET_MSG_TEXT" ] && echo "$RET_MSG_TEXT"
	RET_LOWERED_MSG_TEXT=$(tr '[:upper:]' '[:lower:]' <<<"$RET_MSG_TEXT")

	# Always run modules first to allow them to override any of the
	# case statement below
	run_modules

	case $RET_LOWERED_MSG_TEXT in
	## Not so useful
	'/test'*) tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "BOT is running" ;;
	'.help'*)
		tg --replymarkdownv2msg "$RET_CHAT_ID" "$RET_MSG_ID" "\`.calc\` \\-\\> Do math calculations
\`.magisk\` \\-\\> Get latest magisk stable and canary
\`.fwdpost\` \\-\\> Forward post to @RM6785 \\(this command is restricted to testing group\\)
\`.postupdatesticker\` \\-\\> Post update sticker to @RM6785 \\(this command is restricted to testing group\\)"
		;;

		## Useful utilities
	'.calc'*)
		TRIMMED="${RET_MSG_TEXT#.calc}"
		CALCED=$(echo "$TRIMMED" | bc -l 2>&1)
		if ! echo "$CALCED" | grep -q 'syntax error'; then
			ROUNDED=$(round "$CALCED" 3)
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "$ROUNDED"
		else
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "bruh, did you just entered nonsense, cuz bc ain't happy"
		fi
		;;
	'.magisk'*)
		tg --sendmsg "$RET_CHAT_ID" "Fetching latest Magisk stable"
		LATEST_STABLE=$(
			curl -s https://api.github.com/repos/topjohnwu/Magisk/releases/latest |
				grep "Magisk-v**.*.apk" |
				cut -d : -f 2,3 |
				tr -d \" |
				cut -d, -f2 |
				tr -d '\n' |
				tr -d ' '
		)
		CANARY="https://raw.githubusercontent.com/topjohnwu/magisk-files/canary/app-debug.apk"
		tg --editmarkdownv2msg "$RET_CHAT_ID" "$SENT_MSG_ID" "[Latest stable]($LATEST_STABLE)
[Latest canary]($CANARY)"
		;;
	'.neofetch'*)
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "This may take a while with shitload packages installed in this lappy..."
		NEOFETCH_OUTPUT=$(neofetch --stdout)
		tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "$NEOFETCH_OUTPUT"
		;;

		## Prototypes
	'.fwdpost')
		PREV_POST=$(<"$HOME/.fwdpost_cooldown") || PREV_POST=$(($(date +%s) - 11))
		if [ "$(($(date +%s) - PREV_POST))" -le 10 ]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Wait for 10 secs cooldown plox"
			unset RET_MSG_TEXT
		elif [ "$RET_REPLIED_MSG_ID" = "null" ]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Reply to a message to post plox"
		elif [[ " ${FWD_APRROVED_CHAT_ID[*]} " =~ " $RET_CHAT_ID " ]]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Sending to @RM6785 ..."
			tg --cpmsg "$RET_CHAT_ID" "$FWD_TO" "$RET_REPLIED_MSG_ID"
			tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Post sent"
			date +%s >"$HOME/.fwdpost_cooldown"
		else
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "You aren't allowed to use this command outside testing group"
		fi
		;;
	'.postupdatesticker')
		PREV_STICKER=$(<"$HOME/.stickerpost_cooldown") || PREV_POST=$(($(date +%s) - 11))
		if [ "$(($(date +%s) - PREV_POST))" -le 10 ]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Wait for 10 secs cooldown plox"
			unset RET_MSG_TEXT
		elif [[ " ${FWD_APRROVED_CHAT_ID[*]} " =~ " $RET_CHAT_ID " ]]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Sending to @RM6785 ..."
			tg --sendsticker "$FWD_TO" "$RM6785_UPDATE_STICKER"
			tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Sticker sent"
			date +%s >"$HOME/.stickerpost_cooldown"
		else
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "You aren't allowed to use this command outside testing group"
		fi
		;;

		## Restricted to bot owner
	'.save'*)
		if [ "$MSGGER" -ne "$BOT_OWNER_ID" ]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Sir bro only the bot owner can use this"
			unset RET_MSG_TEXT RET_REPLIED_MSG_ID
			continue
		elif [ "$RET_REPLIED_MSG_ID" = "null" ]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Reply to a message to save thx"
			unset RET_MSG_TEXT RET_REPLIED_MSG_ID
			continue
		fi
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Plox wait ..."
		tg --fwdmsg "$RET_CHAT_ID" "$SAVING_GROUP_ID" "$RET_REPLIED_MSG_ID"
		tg --editmsg "$RET_CHAT_ID" "$SENT_MSG_ID" "Message forwarded"
		;;

		## Funs / Miscs
		#        *sex*) tg --replysticker "$RET_CHAT_ID" "$RET_MSG_ID" "CAACAgUAAxkBAAED-qJiE3HljFCcMMJOY9e12JvDnvk7mAACCAgAAvNoIFQU9d93MQ1XZSME";;
	*t[ea]st[eu]r*mo[ra][er]*p*ro*than*dev*) tg --replysticker "$RET_CHAT_ID" "$RET_MSG_ID" "CAACAgQAAxkBAAED9_FiEMXeRur9aLMvyNnkj02cZew2ggACpAEAAsIupRbTkf08grqV_SME" ;;
	*'@hakimi0804'*)
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Saving this msg lenk for hakimi to read later"
		REPLY_MSG_ID=$SENT_MSG_ID
		tg --sendmsg "$TAGGER_GROUP_ID" "New tag: https://t.me/c/${RET_CHAT_ID#-100}/$RET_MSG_ID"
		tg --delmsg "$RET_CHAT_ID" "$REPLY_MSG_ID"
		;;
	esac

	unset RET_MSG_TEXT RET_REPLIED_MSG_ID
done
