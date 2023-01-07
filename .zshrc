# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable colors and change prompt:
autoload -U colors && colors
autoload -U promptinit; promptinit
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

setopt autocd

# History in cache directory:
HISTSIZE=1000000000
SAVEHIST=1000000000
HISTFILE=~/.cache/zsh/history
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' menu yes select
zstyle ':completion:*:*:make:*' tag-order 'targets'
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1
export VISUAL=nvim

bindkey -M main '^L' forward-char

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

# plugins
source ~/.config/zsh/antigen.zsh
antigen bundle zsh-vi-more/evil-registers
antigen bundle zsh-users/zsh-completions
antigen apply

# nnn cd on exit
if [ -f /usr/share/nnn/quitcd/quitcd.bash_zsh ]; then
    source /usr/share/nnn/quitcd/quitcd.bash_zsh
fi

# ssl conf
export OPENSSL_CONF=/etc/ssl/

path+=('/home/ethan/bin')
path+=('/home/ethan/.emacs.d/bin')
path+=('/home/ethan/.yarn/bin')

# aliases
alias ls="ls --color=auto"
alias ll="ls -lh --color=auto"
alias ec="emacsclient -n"
alias em="emacs -nw"
alias vi="nvim"
alias mupdf="mupdf-gl"
alias 2clip="xclip -selection c"
alias sf="xboard -fcp stockfish -fUCI"
alias gs="git status"
alias gl="git log"
alias ga="git add"
alias gap="git add -p"
alias gc="git commit"
alias gp="git push"
alias gd="git diff"
alias qp="git add . && git commit -m 'update' && git push"
alias qinst="sudo pacman -S"
alias inst="sudo pacman -Syu"
alias uninst="sudo pacman -R"
alias n="n -C"
alias -g ..2='../..'
alias -g ..3='../../..'
alias -g ..4='../../../..'
alias -g ..5='../../../../..'
alias bci="bc -i"
alias ipy="ipython"

export PATH="$PATH:$HOME/.cabal/bin:/home/ethan/.ghcup/bin"
export PATH="$PATH:$HOME/.cargo/bin"

# Setup for android development
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export ANDROID_HOME=$HOME/sandbox/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/sandbox/Android/Sdk
export ANDROID_NDK=$HOME/sandbox/Android/Sdk/ndk/20.1.5948944
export ANDROID_NDK=$HOME/sandbox/Android/Sdk/ndk/20.1.5948944
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/tools
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export NODE_OPTIONS=--openssl-legacy-provider
export PI=192.168.86.68

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /etc/profile.d/autojump.sh
#
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load zsh-syntax-highlighting
# Should be last!
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
