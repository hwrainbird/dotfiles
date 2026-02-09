# PATH setup first - before any commands that depend on it
export JAVA_HOME="/Library/Java/JavaVirtualMachines/liberica-jdk-21.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/share/npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export NPM_CONFIG_CACHE="$HOME/.cache/npm"
export ANDROID_HOME="$HOME/.local/share/android"
export EDITOR="nvim"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

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

# Set up fzf key bindings and fuzzy completion (now that PATH is set)
source <(fzf --zsh)

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
bindkey -M vicmd 'ik' select-in-shell-word  # inner word (like iw)
bindkey -M vicmd 'ak' select-a-shell-word   # around word (like aw)

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

# fzf key bindings and completion (moved after PATH setup)
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
source "/opt/homebrew/opt/fzf/shell/completion.zsh"



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

alias knackserver='node ~/AppDev/Lib/KTL/NodeJS/NodeJS_FileServer.js &'
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
alias knackserver="node /Users/knack/app_dev/Lib/KTL/NodeJS/NodeJS_FileServer.js"
alias rsync="rsync --exclude-from=/Users/knack/.rsync-exclude"
alias cdf="cd \$(find . -type d | fzf)"
alias cdf="cd \"\$(find . -type d | fzf)\""

# Client documentation shortcuts
alias cdocs='cd /Users/knack/clients && ls -la */PROJECT_DOCS.md'
alias fdocs='find /Users/knack/clients -name "PROJECT_DOCS.md" | fzf | xargs nvim'

alias ls="eza"
alias ll="eza -la"
# Initialize tools (after PATH is set)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
autoload -U compinit && compinit
eval "$(carapace _carapace)"
export TASKRC=~/.config/task/taskrc

# Task aliases
alias tnext='task pro.not:learning pro.not:rainbird_apps tnext'

# Carapace completion for taskwarrior
eval "$(carapace _carapace)"

