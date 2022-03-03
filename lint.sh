#!/bin/bash

pr_blue() {
	echo -e "\e[1;34m$*\e[0m"
}

SCRIPTS=$(find -iname '*.sh')
echo "$0"
for script in $SCRIPTS; do
	[ "$script" = "$0" ] && continue
	pr_blue "LINT (SHELLCHECK): $script"
	shellcheck -ax "$script"
done

read -n1 -t5 -r -p "Proceed with shfmt?[y/N]: " SHFMT_PROMPT

[ "$SHFMT_PROMPT" = "y" ] && {
	echo
	for script in $SCRIPTS; do
		pr_blue "LINT (SHFMT): $script"
		shfmt -w "$script"
	done
}
