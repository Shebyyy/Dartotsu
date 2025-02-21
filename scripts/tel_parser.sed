#!/bin/sed -Ef

### md-to-html: Sed script that converts Markdown to Telegram HTML formatting

# Remove Discord mentions
/Discord/d

# Replace Markdown-style lists with Telegram-style bullet points
s/^\* /🔹 /g

# Convert **bold** and __bold__ to <b>bold</b>
s/\*\*([^*]+)\*\*/<b>\1<\/b>/g
s/__(.+?)__/<b>\1<\/b>/g

# Convert *italic* and _italic_ to <i>italic</i>
s/\*([^*]+)\*/<i>\1<\/i>/g
s/_([^_]+)_/<i>\1<\/i>/g

# Convert ~~strikethrough~~ to <s>strikethrough</s>
s/~~([^~]+)~~/<s>\1<\/s>/g

# Convert `inline code` to <code>inline code</code>
s/`([^`]+)`/<code>\1<\/code>/g

# Convert [text](URL) Markdown links to Telegram HTML links
s/\[([^\]]+)\]\(([^)]+)\)/<a href='\2'>\1<\/a>/g
