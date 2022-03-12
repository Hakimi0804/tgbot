#!/bin/bash

modules_load_unload() {
	case $RET_LOWERED_MSG_TEXT in
	'.unload'*)
		if ! is_botowner; then
			err_not_botowner
			return
		fi
		pr_info "modules_load_unload" "Unloading module: ${RET_LOWERED_MSG_TEXT#.unload }"
		local _MODULE_NAME=${RET_LOWERED_MSG_TEXT#.unload }
		local _MODULE_NAME=${_MODULE_NAME#modules/}
		declare -F "${_MODULE_NAME%.sh}" || {
			pr_error "modules_load_unload" "Failed to unload module: ${RET_LOWERED_MSG_TEXT#.unload }, module does not exist"
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Failed to unload module, you sure you typed it correctly?"
			return
		}
		unset "${_MODULE_NAME%.sh}"
		tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "module $_MODULE_NAME unloaded"

		# Also remove it from ${LOADED_MODULES[@]}
		local iteration=0
		for loaded_mod in "${LOADED_MODULES[@]}"; do
			if [ "modules/${_MODULE_NAME%.sh}.sh" = "$loaded_mod" ]; then
				unset "LOADED_MODULES[$iteration]"
				unset iteration
				break
			fi
			((iteration++))
		done
		for loaded_mod in "${LOADED_MODULES[@]}"; do
			local _NEW_LOADED_MODULES+=("$loaded_mod")
		done
		LOADED_MODULES=("${_NEW_LOADED_MODULES[@]}")
		;;
	'.load'*)
		if ! is_botowner; then
			err_not_botowner
			return
		fi
		local _MODULE_NAME=${RET_LOWERED_MSG_TEXT#.load }
		for module in "${LOADED_MODULES[@]}"; do
			if [ "$_MODULE_NAME" = "$module" ]; then
				local _LOAD_ERROR=true
			fi
		done
		if [[ $_LOAD_ERROR == true ]]; then
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "bc that module is already loaded, try unloading it first"
			unset _LOAD_ERROR
		else
			source "$_MODULE_NAME" || {
				tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "Failed to load module, are you sure you typed it correct?"
				return
			}
			LOADED_MODULES+=("$_MODULE_NAME")
			tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "module $_MODULE_NAME loaded"
		fi
		;;
	esac
}
