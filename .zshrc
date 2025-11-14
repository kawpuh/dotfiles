# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable colors and change prompt:
autoload -U colors && colors
autoload -U promptinit; promptinit
setopt autocd

# History in cache directory:
HISTSIZE=1000000000
SAVEHIST=1000000000
mkdir -p ~/.cache/zsh
HISTFILE=~/.cache/zsh/history
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY

# FAST COMPINIT
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -C
else
  compinit
  { compinit; touch ~/.zcompdump } &!
fi
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# vi mode
bindkey -v
export KEYTIMEOUT=1
export VISUAL=nvim
bindkey -M main '^L' forward-char
bindkey -M main '^[l' forward-word

# Change cursor shape for different vi modes.
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
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^e' edit-command-line

# aliases
alias ls="ls --color=auto"
alias ll="ls -lh --color=auto"
alias m="just"
alias vi="nvim"
alias 2clip="tee /dev/tty | xclip -selection c"
alias clip2="xclip -o -selection c"
alias gs="git status"
alias gl="git log"
alias ga="git add"
alias gap="git add -p"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull --recurse-submodules"
alias gd="git diff"
alias gds="git diff --staged"
alias gsub="git submodule update --remote --recursive"
alias t="tmux"
alias view="nvim -R"

up() {
  cd $(printf "%*s" ${1:-1} | tr ' ' '/' | sed 's|/|../|g')
}

seecopy() {
    # Create a temporary file to store the input
    local tmpfile=$(mktemp)

    # Use tee to show input as it comes and save to temp file
    tee "$tmpfile"

    # Now prompt user (reading the saved content)
    echo -n "Copy to clipboard? (y/N): " >&2
    read -r response < /dev/tty

    case "$response" in
        [yY]|[yY][eE][sS])
            if command -v pbcopy >/dev/null 2>&1; then
                pbcopy < "$tmpfile"
                echo "✓ Copied to clipboard" >&2
            elif command -v xclip >/dev/null 2>&1; then
                xclip -selection clipboard < "$tmpfile"
                echo "✓ Copied to clipboard" >&2
            elif command -v wl-copy >/dev/null 2>&1; then
                wl-copy < "$tmpfile"
                echo "✓ Copied to clipboard" >&2
            else
                echo "✗ No clipboard utility found" >&2
            fi
            ;;
        *)
            echo "Not copied" >&2
            ;;
    esac

    # Clean up
    rm "$tmpfile"
}

if [[ $IN_NIX_SHELL ]]; then
    source $HOME/.config/nix.zsh
elif [[ -f $HOME/.config/config.zsh ]]; then
    source $HOME/.config/config.zsh
fi

# Starship (disabled in favor of Powerlevel10k)
# if ! command -v starship &> /dev/null; then
#     echo "Starship not found. Installing..."
#     curl -sS https://starship.rs/install.sh | sh
# fi
# eval "$(starship init zsh)"

# Powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2025-06-06 01:32:35
export PATH="$PATH:/home/ethan/.local/bin"
