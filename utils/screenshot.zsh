#!/usr/bin/env zsh

function screenshot() {
		mkdir -p ~/Pictures/Screenshots
		local filename
		filename=~/Pictures/Screenshots/"Screen Shot $(date +'%Y-%m-%d %H.%M.%S').png"
		screencapture -c "$filename"
		echo "$filename"
		pngpaste "$filename"
}

function screenshot_i() {
		mkdir -p ~/Pictures/Screenshots
		local filename
		filename=~/Pictures/Screenshots/"Screen Shot $(date +'%Y-%m-%d %H.%M.%S').png"
		screencapture -ic "$filename"
		pngpaste "$filename"
}

function screenshot_ui() {
		mkdir -p ~/Pictures/Screenshots
		local filename
		filename=~/Pictures/Screenshots/"Screen Shot $(date +'%Y-%m-%d %H.%M.%S').png"
		screencapture -uUic "$filename"
}

