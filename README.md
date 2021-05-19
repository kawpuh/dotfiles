# dotfiles

# Notes
- libinput > synaptics for touchpad
# Rough Walkthrough
```
su
adduser <user-name> sudo
```
re-log

here's some installs that we might phase out
```
sudo apt install rxvt-unicode emacs i3 i3blocks 
```
install more stuff that we're less likely to imminently replace
```
sudo apt install rofi neovim zsh calibre rclone redshift-gtk curl tmux xcwd fonts-go zsh-autosuggestions zsh-syntax-highlighting feh sxiv autojump git python3-pip python3-jedi libxcb-render0-dev libffi-dev libcairo2 libpangocairo-1.0-0
```
make zsh default shell
```
chsh -s /usr/bin/zsh
```
hard link dotfiles
rename appropriate config files e.g.
```
mv .config/i3/laptop-config config
```
install vim-plug
https://github.com/junegunn/vim-plug
