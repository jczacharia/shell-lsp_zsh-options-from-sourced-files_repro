#!/usr/bin/env zsh
source "$(dirname "$0")/../lib/options.zsh"

answer=${1:-YES}
if [[ ${answer} == (#i)yes ]]; then
	print "matched: extended_glob is on"
fi
print -r -- ${answer} | tr "[:upper:]" "[:lower:]"
