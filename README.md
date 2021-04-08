# dotfiles

# Notes
- libinput > synaptics for touchpad

# Rough Walkthrough
```
su
adduser <user-name> sudo
```
re-log
```
sudo apt install rxvt-unicode emacs i3 rofi neovim zsh calibre rclone redshift-gtk curl tmux xcwd fonts-go zsh-autosuggestions zsh-syntax-highlighting i3blocks feh sxiv autojump git python3-jedi libxcb-render0-dev libffi-dev libcairo2 libpangocairo-1.0-0
```
make zsh default shell
```
chsh -s /usr/bin/zsh
```
hard link dotfiles
rename appropriate i3 config file
```
mv .config/i3/laptop-config config
```
install vim-plug
https://github.com/junegunn/vim-plug
