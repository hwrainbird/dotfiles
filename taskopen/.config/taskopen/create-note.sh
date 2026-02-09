#!/bin/bash

# Get current task data from taskwarrior
# TODO(human): Fix task identification - $UUID variable is not defined
# Need to determine how taskopen passes task information to this script
TASK_TITLE=$(task $UUID export | jq -r '.[0].description // ""')
TASK_PROJECT=$(task $UUID export | jq -r '.[0].project // ""')
TASK_PRIORITY=$(task $UUID export | jq -r '.[0].priority // ""')
TASK_STATUS=$(task $UUID export | jq -r '.[0].status // ""')
TASK_TAGS=$(task $UUID export | jq -r '.[0].tags[]? // empty' | tr '\n' ' ' | sed 's/ $//')
TICKET_ID=$(task $UUID export | jq -r '.[0].ticketid // ""')

# Use Ticket ID format if available, fallback to UUID
if [ -n "$TICKET_ID" ]; then
    FILE="$HOME/notes/task_notes/${TICKET_ID}.md"
else
    FILE="$HOME/notes/task_notes/$UUID.md"
fi

if [ ! -f "$FILE" ]; then
    # Create new file with template
    
    cat > "$FILE" << EOF
# Task Notes: $TASK_TITLE

## Notes












































## Markdown Quick Reference

### Headers
\`# H1\`, \`## H2\`, \`### H3\`

### Emphasis
\`**bold**\`, \`*italic*\`, \`~~strikethrough~~\`

### Lists
- Bullet item
1. Numbered item
- [ ] Checkbox (unchecked)
- [x] Checkbox (checked)

### Links & Code
\`[link text](url)\`
\`\`\`inline code\`\`\`
\`\`\`
code block
\`\`\`

### Other
> Quote block
| Table | Header |
|-------|--------|
| Cell  | Cell   |
EOF
fi

# Open in nvim
nvim "$FILE"
