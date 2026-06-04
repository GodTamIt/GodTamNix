{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  environment.systemPackages = with pkgs; [
    # Basic utilities
    btop
    curl
    dust
    eza
    git
    fish
    procs
    ripgrep
    tmux
    vim
    zsh

    # Default fonts for all systems
    fira-code
    nerd-fonts.fira-code
    noto-fonts
  ];

  programs = {
    fish = enabled;
    zsh = enabled;
  };
}
