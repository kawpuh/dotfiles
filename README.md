# dotfiles

# Usage
```
su
adduser <user-name> sudo
```
re-log
```
sudo apt install rxvt-unicode emacs i3 rofi neovim fish calibre rclone
```
on laptop also do
```
apt install xbacklight
```
make fish default shell
```
chsh -s /usr/bin/fish
```
hard link dotfiles
```
cp -rl .Xresources .spacemacs .config ~/
```
rename i3 config file
```
mv .config/i3/laptop-config config
```
