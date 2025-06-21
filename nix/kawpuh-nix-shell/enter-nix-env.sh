# On your server, create ~/enter-nix-env.sh
#!/bin/sh
cd $HOME/kawpuh-nix-shell
exec nix develop
