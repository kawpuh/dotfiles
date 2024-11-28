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
          ];

          shellHook = ''
            mkdir -p "$HOME/.config"
            mkdir -p "$HOME/.cache/zsh"
            rm -f ".config/config.zsh"
            cp ${zshConfigFile} ".config/config.zsh"
            exec zsh
          '';
        };
      });
}
