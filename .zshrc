# Enable colors and change prompt:
autoload -U colors && colors
fpath+=$HOME/.zsh/pure
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}
# $%b "
autoload -U promptinit; promptinit
prompt pure

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
zstyle ':completion:*' menu select
zstyle ':completion:*:*:make:*' tag-order 'targets'
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1
export VISUAL=nvim

# Use vim keys in tab complete menu:
# bindkey -M menuselect 'h' vi-backward-char
# bindkey -M menuselect 'k' vi-up-line-or-history
# bindkey -M menuselect 'l' vi-forward-char
# bindkey -M menuselect 'j' vi-down-line-or-history
# bindkey -v '^?' backward-delete-char

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

# manage dark mode / light mode

setdark() {
	if [[ $TERM == "xterm-kitty" ]]; then
		kitty @ set-colors ~/.config/kitty/gruvbox_dark.conf
	fi
	export BAT_THEME="OneHalfDark"
	touch ~/.dark
}

setlight() {
	if [[ $TERM == "xterm-kitty" ]]; then
		kitty @ set-colors ~/.config/kitty/gruvbox_light.conf
	fi
	export BAT_THEME="OneHalfLight"
	rm -f ~/.dark
}

if [[ -f "/home/ethan/.dark" ]]; then
	setdark
else
	setlight
fi

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
alias gc="git commit"
alias gp="git push"
alias gd="git diff"
alias inst="sudo pacman -Syu"
alias uninst="sudo pacman -R"
alias n="n -C"
alias -g ..2='../..'
alias -g ..3='../../..'
alias -g ..4='../../../..'
alias -g ..5='../../../../..'

export PATH="$PATH:$HOME/.cabal/bin:/home/ethan/.ghcup/bin"

# Setup for android development
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export ANDROID_HOME=$HOME/sandbox/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/ethan/.autojump/etc/profile.d/autojump.sh
# Load zsh-syntax-highlighting
# Should be last!
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
