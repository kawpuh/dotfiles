{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Substitute package paths in zshrc
        zshConfigFile = pkgs.substituteAll {
          src = ./zshrc;
          p10k = pkgs.zsh-powerlevel10k;
          syntax_highlighting = pkgs.zsh-syntax-highlighting;
          autosuggestions = pkgs.zsh-autosuggestions;
          fzf = pkgs.fzf;
        };

        # Create vim-plug installation script
        vimPlugInstall = pkgs.writeShellScriptBin "install-vim-plug" ''
          PLUG_PATH="$HOME/.local/share/nvim/site/autoload/plug.vim"
          if [ ! -f "$PLUG_PATH" ]; then
            echo "Installing vim-plug..."
            mkdir -p "$(dirname "$PLUG_PATH")"
            curl -fLo "$PLUG_PATH" --create-dirs \
              https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
          fi
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zsh
            zsh-powerlevel10k
            zsh-syntax-highlighting
            zsh-autosuggestions
            fzf
            autojump
            git
            neovim
            tmux
            curl # Required for vim-plug installation
            vimPlugInstall
          ];

          shellHook = ''
            mkdir -p "$HOME/.config"
            mkdir -p "$HOME/.cache/zsh"
            rm -f "$HOME/.config/nix.zsh"
            cp ${zshConfigFile} "$HOME/.config/nix.zsh"
            install-vim-plug
            exec zsh
          '';
        };
      });
}
