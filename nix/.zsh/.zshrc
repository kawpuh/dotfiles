# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable colors and change prompt
autoload -U colors && colors
autoload -U promptinit; promptinit

# Source powerlevel10k
source /nix/store/q8s12w669l6yflzzlzwam8zn53xbji92-powerlevel10k-1.20.0/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

# History settings
HISTSIZE=1000000000
SAVEHIST=1000000000
HISTFILE=~/.cache/zsh/history
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' menu yes select
zstyle ':completion:*:*:make:*' tag-order 'targets'
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# vi mode
bindkey -v
export KEYTIMEOUT=1
export VISUAL=nvim
bindkey -M main '^L' forward-char
bindkey -M main '^[l' forward-word

# Cursor shape function
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} == "" ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Line init function
zle-line-init() {
  zle -K viins
  echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q'
preexec() { echo -ne '\e[5 q' ;}

# Edit line in vim with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^e' edit-command-line

# Basic aliases
alias ls="ls --color=auto"
alias ll="ls -lh --color=auto"
alias vi="nvim"
alias t="tmux"

# Git aliases
alias gs="git status"
alias gl="git log"
alias ga="git add"
alias gap="git add -p"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull --recurse-submodules"
alias gd="git diff"
alias gsub="git submodule update --remote --recursive"

# Source plugins
source /nix/store/ya1s66hgf8h84ivslx24ayjwxyzx82mg-zsh-syntax-highlighting-0.8.0/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /nix/store/z6j94vic2q3z8vfj3ls0m27x7ik06n94-zsh-autosuggestions-0.7.0/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /nix/store/acy4f69mg1cpy98rxsi92cmxv9ariyk9-fzf-0.56.3/share/fzf/key-bindings.zsh
source /nix/store/acy4f69mg1cpy98rxsi92cmxv9ariyk9-fzf-0.56.3/share/fzf/completion.zsh

# Load p10k config if it exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
