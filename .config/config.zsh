alias ask="llm -s \"Only provide essential information. Follow up questions may be asked if necessary. Don't provide superfluous detail initially\""
alias llmc="llm -m claude-3.5-sonnet"
alias llmo="llm -m 4o"
alias llmm="llm -m mistral-large"
commit() {
    local message confirm
    message=$( git diff --no-ext-diff --no-color --staged | llm -m fast -s "Write a commit message. Respond with only the commit message. Keep it simple.")
    echo "$message"
    echo -n "Commit with this message? (y/n): "
    read -r confirm
    if [[ $confirm =~ ^[Yy](es)?$ ]]; then
        git commit -m "$message"
    else
        echo "Commit cancelled."
    fi
}
qcommit() {
    local message
    message=$( git diff --no-ext-diff --no-color --staged | llm -m fast -s "Write a commit message. Respond with only the commit message. Keep it simple.")
    echo "$message"
    git commit -m "$message"
}
alias qinst="sudo pacman -S"
alias inst="sudo pacman -Syu"
alias uninst="sudo pacman -R"
function timertui() {
    termdown $@ && notify-send "Timer Finished" && play ~/Sync/chime.wav
}
alias tm="timertui"
alias cider="clj -Mcider"
alias rebl="clojure -Mrebel"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export OPENSSL_CONF=/etc/ssl/
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export NODE_OPTIONS=--openssl-legacy-provider

# plugins
# First antigen check with additional path
if [ -f /usr/share/zsh/share/antigen.zsh ]; then
    source /usr/share/zsh/share/antigen.zsh
elif [ -f /usr/local/share/zsh/share/antigen.zsh ]; then
    source /usr/local/share/zsh/share/antigen.zsh
elif [ -f /home/ethan/.config/zsh/antigen.zsh ]; then
    source /home/ethan/.config/zsh/antigen.zsh
fi

# Only run antigen commands if antigen was successfully sourced
if type antigen > /dev/null; then
    antigen bundle zsh-vi-more/evil-registers
    antigen bundle zsh-users/zsh-completions
    antigen apply
fi

# Local config check
[[ -f $HOME/.config/local.zsh ]] && source $HOME/.config/local.zsh
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /etc/profile.d/autojump.sh ]; then
    source /etc/profile.d/autojump.sh
elif [ -f /usr/local/etc/profile.d/autojump.sh ]; then
    source /usr/local/etc/profile.d/autojump.sh
fi

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
