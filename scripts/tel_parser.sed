#!/bin/sed -Ef

### md-to-html: Sed script that converts Markdown to HTML code

# s/◗//
/Discord/d
s/%0A/\n/g
s/-/●/
s/●/●/

s/\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+) *\] *\( *([^ ]+) *\)/<a href='\2'>\1<\/a>/g

# **text** and __text__
s/(^|[^\\\*])\*{2}([^\*]+)\*{2}([^\*]|$)/\1\2\3/g
s/(^|[^\\_])_{2}([^\_]+)_{2}([^_]|$)/\1<strong>\2<\/strong>\3/g

# *text* and _text_
s/(^|[^\\\*])\*([^\*]+)\*([^\*]|$)/\1<em>\2<\/em>\3/g
s/(^|[^\\_])_([^_]+)_([^_]|$)/\1<em>\2<\/em>\3/g

# ~~text~~
s/(^|[^\\~])~~([^~]+)~~([^~]|$)/\1<del>\2<\/del>\3/g
s/(^|[^\\~])~([^~]+)~([^~]|$)/\1<s>\2<\/s>\3/g

# `text`
s/(^|[^\\`])`([^`]+)`([^`]|$)/\1<code>\2<\/code>\3/g