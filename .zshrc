# Enable colors and change prompt:
autoload -U colors && colors
fpath+=$HOME/.zsh/pure
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}
# $%b "
autoload -U promptinit; promptinit
prompt pure

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
source /usr/local/share/zsh-antigen/antigen.zsh
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
alias bat="batcat"
alias gs="git status"
alias gl="git log"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gd="git diff"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$PATH:$HOME/.cabal/bin:/home/ethan/.ghcup/bin"

# Setup for android development
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Load zsh-syntax-highlighting
# Should be last!
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/autojump/autojump.zsh 2>/dev/null
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
