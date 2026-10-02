# PATH setup first - before any commands that depend on it
if [[ $OSTYPE == darwin* ]]; then
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/liberica-jdk-21.jdk/Contents/Home"
else
  export JAVA_HOME="/usr/lib/jvm/default"   # Arch: pick the version with archlinux-java
fi
export PATH="$JAVA_HOME/bin:$PATH"
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/share/npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export NPM_CONFIG_CACHE="$HOME/.cache/npm"
export ANDROID_HOME="$HOME/.local/share/android"
export EDITOR="nvim"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export RAILWAY_CONFIG_DIR="$HOME/.config/railway"
export MBSYNCRC="$HOME/.config/mbsync/mbsyncrc"
[[ -f "$ZDOTDIR/secrets.zsh" ]] && source "$ZDOTDIR/secrets.zsh"

# XDG environment variables for applications
export NOTMUCH_CONFIG="$HOME/.config/notmuch/notmuchrc"

# Aliases
alias flash-sweep='qmk flash -kb splitkb/aurora/sweep -km my_sweep'
alias nvim-lazy='NVIM_APPNAME=nvim-lazyvim nvim'
alias nvim-kick='nvim'
alias clear="printfddd"
alias clear='printf "\033[2J\033[H"'
alias mutt='neomutt'
alias fv='nvim $(fzf -m --preview="bat --color=always {}")'
alias invoice=~/clients/rainbird_apps/invoicing/.venv/bin/invoice


# History. macOS's /etc/zshrc sets these for you; on Linux zsh saves nothing without them.
HISTSIZE=10000
SAVEHIST=10000

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Use beam shape cursor for each new prompt
preexec() { echo -ne '\e[5 q' ;}

# Colemak navigation (mnei = hjkl)
bindkey -M vicmd 'm' vi-backward-char
bindkey -M vicmd 'n' vi-down-line-or-history
bindkey -M vicmd 'e' vi-up-line-or-history
bindkey -M vicmd 'i' vi-forward-char

# Insert mode mapping (k = i in Colemak) 
bindkey -M vicmd 'k' vi-insert
bindkey -M vicmd 'K' vi-insert-bol

# Text objects - inner mappings for vi motions
bindkey -M vicmd 'kw' select-in-shell-word   # inner word (k = i in Colemak)
bindkey -M vicmd 'aw' select-a-shell-word    # around word


# End of word (h = e in Colemak)
bindkey -M vicmd 'h' vi-forward-word-end

# Search navigation (j for next, since n is down)
bindkey -M vicmd 'j' vi-repeat-search
bindkey -M vicmd 'J' vi-rev-repeat-search

# Undo (l = u in Colemak)
bindkey -M vicmd 'l' undo

# jj to escape from insert mode
bindkey -M viins 'jj' vi-cmd-mode

# Enable searching through history
bindkey '^R' history-incremental-search-backward

# fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Better fzf defaults
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Aliases for power user workflow
alias lg='lazygit'
alias t='tmux'
alias ta='tmux attach'
alias tls='tmux list-sessions'
alias cc='claude'

# fzf key bindings and completion. Sourced after the bindkey lines above so
# fzf's Ctrl-R wins over plain history search. Works wherever fzf is installed.
source <(fzf --zsh)



# Client workspace system
export PATH="$HOME/bin:$PATH"

# Client workflow aliases
alias cw="client-work"
alias ct="task rc:.taskrc"              # Client tasks
alias cn="nb"                           # Client notes
alias cg="lazygit"                      # Client git

# Context-dependent task function for client workspaces
task() {
    if [[ "$PWD" == */clients/* ]] && [[ -f "./taskrc" ]]; then
        local client_name=$(basename "$PWD")
        if [[ "$1" == "add" ]]; then
            TASKRC=./taskrc command task add project:$client_name "${@:2}"
        else
            TASKRC=./taskrc command task project:$client_name "$@"
        fi
    else
        command task "$@"
    fi
}

export PATH="$HOME/.local/bin:$PATH"
alias topen="taskopen --include=markdown"

# Timewarrior summary by task ID
tsummary() {
    if [[ -z "$1" ]]; then
        echo "Usage: tsummary <task_id>"
        return 1
    fi
    local task_desc=$(task $1 export 2>/dev/null | jq -r '.[0].description' 2>/dev/null)
    if [[ -z "$task_desc" || "$task_desc" == "null" ]]; then
        echo "Task $1 not found"
        return 1
    fi
    timew summary "$task_desc"
}

# Workflow documentation
alias workflow-guide="nvim ~/WORKFLOW_GUIDE.md"
alias workflow-view="nb show rainbird_apps:2 | glow"
alias knackserver="node $HOME/app_dev/Lib/KTL/NodeJS/NodeJS_FileServer.js $HOME/app_dev"
alias rsync="rsync --exclude-from=$HOME/.config/rsync/exclude"
alias cdf="cd \$(find . -type d | fzf)"
alias cdf="cd \"\$(find . -type d | fzf)\""

# Client documentation shortcuts (legacy — kept for back-compat, prefer k / kfind)
alias cdocs='cd ~/clients && ls -la */PROJECT_DOCS.md'
alias fdocs='find ~/clients -name "PROJECT_DOCS.md" | fzf | xargs nvim'

# --- kb: per-client knowledge base ---
# Plain markdown files at ~/clients/<client>/KNOWLEDGE.md. Edited in $EDITOR.
# The CLI lives at ~/bin/kb; the helpers below wrap it for fast typing.
# Also: `work <id> done` nudges you to log notes as KB issues automatically.
kb-detect-cwd() {
  case "$PWD" in
    "$HOME/clients/"*) basename "${PWD#$HOME/clients/}" ;;
    *) echo "" ;;
  esac
}
k() {                                       # open client KB (auto-detect from cwd)
  local c="${1:-$(kb-detect-cwd)}"
  [ -z "$c" ] && { echo "Not in a client dir. Usage: k <client>"; return 1; }
  "$HOME/bin/kb" "$c"
}
kissue() {                                  # add an issue (interactive)
  local c="${1:-$(kb-detect-cwd)}"
  [ -z "$c" ] && { echo "Not in a client dir. Usage: kissue <client>"; return 1; }
  "$HOME/bin/kb" issue "$c"
}
kfind() {                                   # grep across all client KBs
  [ -z "$1" ] && { echo "Usage: kfind <term>"; return 1; }
  "$HOME/bin/kb" find "$1"
}
ktoday() { "$HOME/bin/kb" today "${@:--d 7}"; }

alias ls="eza"
alias ll="eza -la"
# Initialize tools (after PATH is set)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
autoload -U compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
eval "$(carapace _carapace)"
export TASKRC=~/.config/task/taskrc

# Task aliases
alias tnext='task pro.not:learning pro.not:rainbird_apps tnext'

# Carapace completion for taskwarrior
eval "$(carapace _carapace)"

# Go-installed binaries (default GOPATH)
export PATH="$PATH:$HOME/go/bin"

# television shell integration: Ctrl-T smart autocomplete, Ctrl-R history.
# Loaded after fzf so tv takes over those two keys; delete this line to give them back to fzf.
eval "$(tv init zsh)"

# herdr: name ad-hoc panes after their directory, live as you cd.
# Panes built by `work start` carry WORK_PANE_ROLE (notes/claude/shell) and
# keep their role name. Backgrounded so a slow socket never delays a prompt.
if [[ -n $HERDR_PANE_ID && -z $WORK_PANE_ROLE ]] && (( $+commands[herdr] )); then
  _herdr_name_pane() {
    herdr pane rename "$HERDR_PANE_ID" "${${PWD/#$HOME/~}:t}" >/dev/null 2>&1 &!
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd _herdr_name_pane
  _herdr_name_pane
fi
