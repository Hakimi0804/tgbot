#!/bin/bash

[ -d modules ] || {
	echo "No modules directory found, skipping module loading"
	run_modules() { true; }
	return
}

load_modules() {
	MODULES=$(find modules -iname '*.sh')
	MODULES_EXCLUDE=(
		# An array of modules to be excluded,
		# can be used for debugging or temporary disablement.
		"modules/hakimi_afk.sh"
	)

	unset LOADED_MODULES
	for module in $MODULES; do
		for exclude_module in "${MODULES_EXCLUDE[@]}"; do
			if [ "$module" = "$exclude_module" ]; then
				pr_info "modules_loader" "SKIP MODULE: $module"
				continue 2
			fi
		done
		pr_info "modules_loader" "LOAD MODULE: $module"
		source "$module"
		LOADED_MODULES+=("$module")
	done
	[[ -n ${LOADED_MODULES[*]} ]] && pr_info "modules_loader" "LOADED: ${LOADED_MODULES[*]}\n"
}

run_modules() {
	for module in "${LOADED_MODULES[@]}"; do
		FUNCTION_NAME=$(basename "$module")
		FUNCTION_NAME=${FUNCTION_NAME%.sh}
		"$FUNCTION_NAME"
	done
}

load_modules
trap 'pr_info "modules_loader" "Reloading modules"; load_modules' SIGINT
