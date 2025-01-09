alias ask="llm -s \"Only provide essential information. Follow up questions may be asked if necessary. Don't provide superfluous detail initially\""
alias llmc="llm -m claude-3.5-sonnet"
alias llmo="llm -m 4o"
alias llmm="llm -m mistral-large"
commit() {
    local message confirm
    message=$( git diff --no-ext-diff --no-color --staged | llm -m openrouter/google/gemini-2.0-flash-exp:free -s "Write a commit message. Respond with only the commit message.")
    echo "$message"
    echo -n "Commit with this message? (y/n): "
    read -r confirm
    if [[ $confirm =~ ^[Yy](es)?$ ]]; then
        git commit -m "$message"
    else
        echo "Commit cancelled."
    fi
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
if [ -f /usr/share/zsh/share/antigen.zsh ]; then
    source /usr/share/zsh/share/antigen.zsh
elif [ -f /home/ethan/.config/zsh/antigen.zsh ]; then
    source /home/ethan/.config/zsh/antigen.zsh
fi
antigen bundle zsh-vi-more/evil-registers
antigen bundle zsh-users/zsh-completions
antigen apply

[[ -f $HOME/.config/local.zsh ]] && source $HOME/.config/local.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /etc/profile.d/autojump.sh

# Load zsh-syntax-highlighting
# Should be last!
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
