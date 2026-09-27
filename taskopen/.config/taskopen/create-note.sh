#!/usr/bin/env bash
# taskopen "Notes" action: resolve (or create) a task's note file and open it.
#
# taskopenrc passes $UUID and $TASK_* as positional arguments (taskopen sets
# them as environment variables and the command line expands them). Note
# creation is delegated to the taskwarrior on-add hook's script so there is
# exactly one note template in the system.
set -eu

UUID="${1:-}"
TICKET_ID="${2:-}"
PROJECT="${3:-}"
DESCRIPTION="${4:-}"

# An argument that is still a literal "$NAME" means taskopenrc didn't expand
# it (single quotes do that). Stop rather than create a note called
# "$TASK_TICKETID.md", which is what happened on 2026-09-25.
for arg in "$UUID" "$TICKET_ID" "$PROJECT"; do
    case "$arg" in
        '$'[A-Z]*)
            echo "create-note: taskopen passed '$arg' unexpanded; check the quoting in taskopenrc" >&2
            exit 1
            ;;
    esac
done

RESOLVER="$HOME/bin/lib/shared/note_paths.py"
CREATOR="$HOME/.config/task/scripts/create-task-notes.py"
EDITOR_CMD="${EDITOR:-nvim}"

FILE="$(python3 "$RESOLVER" find "$TICKET_ID" "$UUID" 2>/dev/null || true)"

if [ -z "$FILE" ]; then
    ID="${TICKET_ID:-$UUID}"
    if [ -z "$ID" ]; then
        echo "create-note: no ticket id or uuid supplied by taskopen" >&2
        exit 1
    fi
    python3 -c 'import json,sys; print(json.dumps({
        "uuid": sys.argv[1], "ticketid": sys.argv[2],
        "description": sys.argv[3], "project": sys.argv[4], "entry": ""}))' \
        "$UUID" "$ID" "$DESCRIPTION" "$PROJECT" \
        | python3 "$CREATOR" >/dev/null
    FILE="$(python3 "$RESOLVER" find "$ID" "$UUID" 2>/dev/null || true)"
fi

if [ -z "$FILE" ]; then
    echo "create-note: could not resolve a note path" >&2
    exit 1
fi

exec "$EDITOR_CMD" "$FILE"
