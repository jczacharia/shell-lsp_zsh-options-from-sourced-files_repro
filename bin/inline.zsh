#!/usr/bin/env zsh
setopt pipe_fail extended_glob

answer=${1:-YES}
if [[ ${answer} == (#i)yes ]]; then
	print "matched: extended_glob is on"
fi
print -r -- ${answer} | tr "[:upper:]" "[:lower:]"
