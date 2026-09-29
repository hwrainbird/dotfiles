#!/usr/bin/env bash
#
# setup-omarchy.sh — install my software and dotfiles on a fresh Omarchy machine.
#
# Usage:
#   git clone https://github.com/hwrainbird/dotfiles ~/dotfiles
#   ~/dotfiles/setup-omarchy.sh
#
# The only prompts (sudo password, GitHub login) happen in the first minute,
# then it runs unattended. Safe to re-run: every step skips work already done.
#
# To drop something, delete its line (or comment it out with #) in one of the
# lists below. Each list installs as one batch; if the batch fails, it retries
# item by item and prints whatever failed at the end.
#
# Omarchy already ships these, so they are not in the lists:
#   neovim, tmux, herdr, starship, fzf, fd, ripgrep, bat, eza, zoxide, lazygit,
#   jq, llvm, imagemagick, ffmpegthumbnailer, docker, mpv, chromium, obsidian,
#   localsend, yt-dlp, tldr, btop, JetBrains Mono Nerd Font

set -euo pipefail

# ─── Settings ────────────────────────────────────────────────────────────────

DOTFILES_REPO="https://github.com/hwrainbird/dotfiles.git"  # public, no login needed
DOTFILES_DIR="$HOME/dotfiles"
SCRIPTS_REPO="hwrainbird/scripts"                           # private, cloned with gh
SCRIPTS_DIR="$HOME/bin"
# Anything that blocks a symlink gets moved here, never deleted
BACKUP_DIR="$HOME/.local/state/setup-omarchy/backup-$(date +%Y%m%d-%H%M%S)"

# ─── Official Arch packages (pacman) ─────────────────────────────────────────

PACMAN_PKGS=(
  # Shell & terminal
  zsh                     # login shell (Omarchy defaults to bash)
  stow                    # symlinks ~/dotfiles packages into $HOME
  wezterm                 # terminal emulator (dotfiles: wezterm)
  zellij                  # terminal multiplexer (dotfiles: zellij)
  atuin                   # shell history search
  television              # fuzzy finder TUI, `tv` (dotfiles: television)
  yazi                    # terminal file manager (dotfiles: yazi)
  poppler                 # PDF tools; yazi uses it for PDF previews
  7zip                    # archive tool; yazi uses it for archive previews
  chafa                   # image-to-text; yazi uses it for image previews
  resvg                   # SVG renderer; yazi uses it for SVG previews
  unarchiver              # `unar`; yazi's "Extract here" opener runs it
  ttf-hack-nerd           # Hack Nerd Font

  # Git & programming
  github-cli              # `gh`; also the credential helper in your git config
  git-lfs                 # Git LFS; your git config requires it
  gitleaks                # secret scanner; your global pre-commit hook runs it
  go                      # Go toolchain
  nodejs                  # Node.js runtime
  npm                     # Node package manager (globals → ~/.local/share/npm-global)
  uv                      # Python tool manager; installs the Python CLIs below
  jdk21-openjdk           # Java 21 (Liberica 21 on the Mac)
  nim                     # Nim compiler
  stack                   # Haskell Stack
  android-tools           # adb and fastboot
  qmk                     # QMK firmware CLI; used by the `flash-sweep` alias

  # Tasks, time & notes
  task                    # Taskwarrior 3 (dotfiles: task)
  timew                   # Timewarrior; Taskwarrior's on-modify hook calls it
  zk                      # Zettelkasten notes CLI
  calcurse                # terminal calendar
  glow                    # terminal markdown renderer
  pass                    # password store; mbsync reads your IMAP password from it

  # Email
  neomutt                 # mail client (dotfiles: neomutt)
  isync                   # `mbsync`, IMAP sync (dotfiles: mbsync)
  notmuch                 # mail search/index (dotfiles: notmuch)
  himalaya                # CLI email client
  urlscan                 # pick URLs out of emails in neomutt

  # Web & network
  lynx                    # text-mode browser
  links                   # text-mode browser
  elinks                  # text-mode browser (replaces Homebrew's felinks)
  mosh                    # roaming SSH
  atac                    # TUI API client, like Postman

  # Files & AI
  qpdf                    # PDF split/merge/repair
  ollama                  # local LLMs; for GPU use ollama-cuda (NVIDIA) or ollama-rocm (AMD)

  # Desktop apps
  firefox                 # browser
  vivaldi                 # browser
  thunderbird             # email client
  telegram-desktop        # Telegram
  bitwarden               # Bitwarden password manager (desktop app)
  calibre                 # ebook manager
  anki                    # flashcards
  proton-vpn-gtk-app      # Proton VPN
  tailscale               # Tailscale VPN (service enabled below)
  remmina                 # VNC/RDP client; replaces Screens 5
  solaar                  # Logitech device manager; replaces Logi Options+
)

# ─── AUR packages (yay) ──────────────────────────────────────────────────────

AUR_PKGS=(
  carapace-bin            # shell completions; .zshrc runs `carapace _carapace`
  nb                      # notes/bookmarks CLI; `cn` alias and workflow-view
  taskopen                # open task annotations; `topen` alias (dotfiles: taskopen)
  ssss                    # Shamir's secret sharing
  brave-bin               # Brave browser
  visual-studio-code-bin  # VS Code
  teamviewer              # TeamViewer (its daemon is enabled below)
  ngrok                   # tunnels to localhost
  slack-cli               # Slack platform CLI
  balena-etcher           # USB image flasher
  safeeyes                # break reminders; replaces LookAway
)

# ─── Global npm packages ─────────────────────────────────────────────────────

NPM_PKGS=(
  @bitwarden/cli                  # `bw`, Bitwarden CLI
  @earendil-works/pi-coding-agent # pi coding agent
  @fission-ai/openspec            # OpenSpec
  @hubspot/cli                    # HubSpot CLI
  @vue/cli                        # Vue CLI
  @railway/cli                    # Railway CLI (Homebrew `railway` on the Mac)
  @steipete/summarize             # summarize (Homebrew `summarize` on the Mac)
  clawhub                         # ClawHub CLI
  eslint                          # JS linter
  mcporter                        # MCP server CLI
  netlify-cli                     # Netlify CLI
  openclaw                        # OpenClaw
  pnpm                            # package manager
  prettier                        # code formatter
  turbo                           # Turborepo
  typescript                      # `tsc`
  yarn                            # package manager
)

# ─── Python CLI tools (uv tool) ──────────────────────────────────────────────

UV_TOOLS=(
  pre-commit              # git hook framework; used by repo-checks templates
  nano-pdf                # PDF editing CLI
  zmk                     # ZMK keyboard firmware CLI (pipx on the Mac)
  rich-cli                # `rich` in the terminal (Homebrew on the Mac)
  openai-whisper          # speech-to-text; large download (pulls in PyTorch)
)

# ─── Web apps (Omarchy launcher entries) ─────────────────────────────────────
# Format: "Name|URL|icon". Icons come from https://dashboard-icons.homarr.dev

WEBAPPS=(
  "Fastmail|https://app.fastmail.com|fastmail"
  "Claude|https://claude.ai|claude-ai"                         # desktop app is Mac-only
  "ChatGPT|https://chatgpt.com|chatgpt"
  "Notion|https://www.notion.so|notion"
  "ClickUp|https://app.clickup.com|clickup"
  "WhatsApp|https://web.whatsapp.com|whatsapp"
  "Zoom|https://app.zoom.us/wc/home|zoom"
  "Microsoft Word|https://www.office.com/launch/word|microsoft-word"
  "Microsoft Excel|https://www.office.com/launch/excel|microsoft-excel"
  "Microsoft Teams|https://teams.microsoft.com|microsoft-teams"
  "Pushover|https://client.pushover.net|pushover"
  "reMarkable|https://my.remarkable.com|remarkable"          # desktop app is Mac/Win-only
  "Prime Video|https://www.primevideo.com|prime-video"
)

# ─── Dotfiles packages to stow ───────────────────────────────────────────────
# macOS-only packages (karabiner, skhd, yabai) are left out on purpose.

STOW_PKGS=(
  zsh                     # ~/.config/zsh (.zshrc)
  git                     # ~/.config/git (config, global ignore, pre-commit hook)
  nvim                    # ~/.config/nvim (your LazyVim config replaces Omarchy's)
  starship                # ~/.config/starship (prompt + custom modules)
  wezterm                 # ~/.config/wezterm
  zellij                  # ~/.config/zellij
  herdr                   # ~/.config/herdr
  television              # ~/.config/television
  yazi                    # ~/.config/yazi
  ripgrep                 # ~/.config/ripgrep
  rsync                   # ~/.config/rsync (exclude list)
  task                    # ~/.config/task (taskrc + hooks)
  taskopen                # ~/.config/taskopen
  timewarrior             # ~/.config/timewarrior
  mbsync                  # ~/.config/mbsync
  neomutt                 # ~/.config/neomutt
  notmuch                 # ~/.config/notmuch
  workflow                # ~/.config/workflow + repo-checks in ~/.local
)

# ─── Services to enable at boot ──────────────────────────────────────────────
# Any service whose package you removed above is skipped automatically.

SERVICES=(
  tailscaled              # Tailscale; then run `sudo tailscale up` once
  ollama                  # Ollama server (models are stored in /var/lib/ollama)
  teamviewerd             # TeamViewer daemon
)

# ─── Not installed: no Linux version, or Omarchy already covers it ───────────
#   yabai, skhd, Magnet          → Hyprland tiling with Omarchy's keybindings
#   Karabiner-Elements           → Hyprland input settings (~/.config/hypr)
#   Raycast, Shortcat            → Omarchy's app launcher
#   Paste                        → Omarchy's clipboard history
#   CleanShot X                  → Omarchy's screenshot tool
#   Flux                         → Omarchy's nightlight (hyprsunset)
#   Hammerspoon, cliclick        → Hyprland dispatchers, wtype
#   GrandPerspective             → dua-cli (ships with Omarchy)
#   OpenMTP                      → Nautilus + gvfs-mtp (ship with Omarchy)
#   iTerm2, Warp                 → you use WezTerm (Warp: AUR warp-terminal-bin)
#   z                            → replaced by zoxide
#   colemak-dh layout            → your Mac runs British layout; Colemak lives in the Sweep firmware
#   Authy Desktop                → discontinued
#   4K Video Downloader+         → yt-dlp covers it
#   Apple apps, xcodegen, CotEditor, DevUtils, MeetingBar, Quitter, QuickDrop,
#   SpaceId, Productive, Cold Turkey, Garmin apps, Dr.Fone → macOS/Windows only
#   respite                      → local project in ~/src with no git remote

# ═════════════════════════════════════════════════════════════════════════════
# Everything below does the work. You shouldn't need to edit it.
# ═════════════════════════════════════════════════════════════════════════════

FAILED=()   # everything that didn't install; printed at the end

section() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
info()    { printf '    %s\n' "$*"; }
warn()    { printf '\033[1;33m    ! %s\033[0m\n' "$*"; }

# One installer per source. Each takes package names as arguments.
pacman_install() { sudo pacman -S --needed --noconfirm "$@"; }
aur_install()    { yay -S --needed --noconfirm --answerdiff None --answerclean None "$@"; }
npm_install()    { npm install --global "$@"; }
# Pinned to a uv-managed Python so Arch's system Python upgrades can't break the tools
uv_install()     { local t; for t in "$@"; do uv tool install --python 3.12 "$t" || return 1; done; }

# Try the whole list in one go (fast). If that fails, one bad package would
# otherwise block the rest, so retry each on its own and record the failures.
install_list() {
  local installer=$1; shift
  (( $# )) || return 0
  "$installer" "$@" && return 0
  warn "Batch install failed; retrying one package at a time"
  local pkg
  for pkg in "$@"; do
    "$installer" "$pkg" || FAILED+=("$pkg")
  done
}

# Move whatever would block stowing a package into $BACKUP_DIR. Works at the
# app-folder level (~/.config/<app>, ~/.local/bin/<file>, ~/.local/share/<app>),
# so Omarchy's whole nvim config moves aside instead of merging with yours.
backup_conflicts() {
  local pkg=$1 src rel target
  for src in "$DOTFILES_DIR/$pkg"/.config/* \
             "$DOTFILES_DIR/$pkg"/.local/bin/* \
             "$DOTFILES_DIR/$pkg"/.local/share/*; do
    [[ -e $src ]] || continue                     # the glob matched nothing
    rel=${src#"$DOTFILES_DIR/$pkg/"}              # e.g. .config/nvim
    target="$HOME/$rel"
    [[ -e $target || -L $target ]] || continue    # nothing in the way
    [[ $(readlink -f "$target") == "$DOTFILES_DIR"/* ]] && continue  # already ours
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
    info "Moved existing ~/$rel to the backup folder"
  done
}

# ─── 1. Preflight: every prompt happens here, then it runs unattended ────────

section "Checking this is Omarchy"
[[ -f /etc/arch-release ]]  || { echo "This script is for Arch Linux / Omarchy."; exit 1; }
[[ $EUID -ne 0 ]]           || { echo "Run as your normal user; the script calls sudo itself."; exit 1; }
command -v yay >/dev/null   || { echo "yay not found. Is this an Omarchy install?"; exit 1; }

section "Asking for your sudo password"
sudo -v
# Refresh sudo in the background so long AUR builds don't stop at a password prompt
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

section "Updating the system and installing GitHub CLI"
# Arch doesn't support partial upgrades, so sync and upgrade everything in
# the same step that installs the first new package
sudo pacman -Syu --needed --noconfirm github-cli

section "Logging in to GitHub (needed for your private scripts repo)"
gh auth status >/dev/null 2>&1 || gh auth login --git-protocol https --web

# ─── 2. Packages ─────────────────────────────────────────────────────────────

section "Installing official Arch packages"
install_list pacman_install "${PACMAN_PKGS[@]}"

section "Installing AUR packages"
install_list aur_install "${AUR_PKGS[@]}"

# ─── 3. Language tools ───────────────────────────────────────────────────────

section "Installing global npm packages"
# Same XDG layout as the Mac: config in ~/.config/npm, globals in ~/.local/share
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/npmrc"
export PATH="$HOME/.local/share/npm-global/bin:$HOME/.local/bin:$PATH"
if [[ ! -f $NPM_CONFIG_USERCONFIG ]]; then
  mkdir -p "$(dirname "$NPM_CONFIG_USERCONFIG")" "$HOME/.local/share/npm-global"
  printf 'prefix=%s\ncache=%s\n' "$HOME/.local/share/npm-global" "$HOME/.cache/npm" \
    >"$NPM_CONFIG_USERCONFIG"
fi
install_list npm_install "${NPM_PKGS[@]}"

section "Installing Python CLI tools"
install_list uv_install "${UV_TOOLS[@]}"

section "Installing Claude Code"
if command -v claude >/dev/null; then
  info "Already installed"
else
  curl -fsSL https://claude.ai/install.sh | bash || FAILED+=("claude-code")
fi

# ─── 4. Web apps ─────────────────────────────────────────────────────────────

section "Adding web apps to the launcher"
for entry in "${WEBAPPS[@]}"; do
  IFS='|' read -r name url icon <<<"$entry"
  if [[ -f "$HOME/.local/share/applications/$name.desktop" ]]; then
    info "$name: already there"
    continue
  fi
  omarchy-webapp-install "$name" "$url" \
    "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/$icon.png" \
    || FAILED+=("webapp:$name")
done

# ─── 5. Dotfiles & scripts ───────────────────────────────────────────────────

section "Getting dotfiles"
if [[ -d $DOTFILES_DIR/.git ]]; then
  info "Already cloned at $DOTFILES_DIR"
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

section "Writing ~/.zshenv"
# zsh reads ~/.zshenv before anything else; it points zsh at ~/.config/zsh.
# This is the Mac's ~/.zshenv minus the Homebrew PATH line and the Ollama
# paths (the systemd service keeps its models in /var/lib/ollama).
zshenv_tmp=$(mktemp)
cat >"$zshenv_tmp" <<'EOF'
export ZDOTDIR="$HOME/.config/zsh"
export HISTFILE="$HOME/.local/state/zsh/history"
export ZSH_COMPDUMP="$HOME/.cache/zsh/compdump"
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/npmrc"
export NOTMUCH_CONFIG="$HOME/.config/notmuch/notmuchrc"
export NODE_REPL_HISTORY="$HOME/.local/state/node/repl_history"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export MBSYNCRC="$HOME/.config/mbsync/mbsyncrc"
EOF
if cmp -s "$zshenv_tmp" "$HOME/.zshenv"; then
  info "Already up to date"
  rm "$zshenv_tmp"
else
  if [[ -e $HOME/.zshenv ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$HOME/.zshenv" "$BACKUP_DIR/.zshenv"
    info "Moved existing ~/.zshenv to the backup folder"
  fi
  mv "$zshenv_tmp" "$HOME/.zshenv"
fi
# The folders those variables point at must exist
mkdir -p "$HOME/.local/state/zsh" "$HOME/.cache/zsh" "$HOME/.local/state/node"

section "Linking dotfiles with stow"
# Stow symlinks the highest folder it can. If ~/.local/share didn't exist it
# would link the whole folder into the repo, and every app writing there would
# write into ~/dotfiles. Creating the shared parents keeps links at app level.
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share"
for pkg in "${STOW_PKGS[@]}"; do
  if [[ ! -d $DOTFILES_DIR/$pkg ]]; then
    warn "$pkg: not in $DOTFILES_DIR, skipping"
    FAILED+=("stow:$pkg")
    continue
  fi
  backup_conflicts "$pkg"
  stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg" \
    && info "$pkg: linked" \
    || FAILED+=("stow:$pkg")
done

section "Getting your scripts (~/bin)"
if [[ -d $SCRIPTS_DIR/.git ]]; then
  info "Already cloned at $SCRIPTS_DIR"
elif [[ -d $SCRIPTS_DIR ]] && [[ -n $(ls -A "$SCRIPTS_DIR") ]]; then
  warn "$SCRIPTS_DIR exists and isn't empty; not touching it"
  FAILED+=("scripts-repo")
else
  gh repo clone "$SCRIPTS_REPO" "$SCRIPTS_DIR" || FAILED+=("scripts-repo")
fi

# ─── 6. Finishing touches ────────────────────────────────────────────────────

section "Installing Neovim plugins"
nvim --headless "+Lazy! sync" +qa || FAILED+=("nvim-plugins")

section "Installing Yazi plugins"
ya pkg install || FAILED+=("yazi-plugins")

section "Enabling services"
for svc in "${SERVICES[@]}"; do
  if ! systemctl cat "$svc.service" >/dev/null 2>&1; then
    info "$svc: not installed, skipping"
    continue
  fi
  sudo systemctl enable --now "$svc.service" \
    && info "$svc: enabled" \
    || FAILED+=("service:$svc")
done

section "Making zsh your login shell"
zsh_path=$(command -v zsh)
if [[ $(getent passwd "$USER" | cut -d: -f7) == "$zsh_path" ]]; then
  info "Already zsh"
else
  sudo chsh -s "$zsh_path" "$USER"
  info "Done; takes effect next time you log in"
fi

# ─── 7. Summary ──────────────────────────────────────────────────────────────

section "Done"
if (( ${#FAILED[@]} )); then
  warn "These didn't install. Scroll up for the errors:"
  printf '      - %s\n' "${FAILED[@]}"
fi
[[ -d $BACKUP_DIR ]] && info "Replaced files were moved to: $BACKUP_DIR"

cat <<'EOF'

    Manual steps left:
      1. Copy ~/.config/zsh/secrets.zsh from the Mac (gitignored on purpose)
      2. Import your GPG key and clone ~/.password-store (mbsync gets your IMAP password from `pass`)
      3. sudo tailscale up
      4. ollama pull <model>
      5. qmk setup   (only if you still flash the Sweep with QMK)
      6. Log out and back in so zsh becomes your shell
EOF
