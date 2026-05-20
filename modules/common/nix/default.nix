{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  environment.systemPackages = with pkgs;
    [
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
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # Linux-only: libva-utils references libdrm; pciutils is Linux PCI bus tooling
      libva-utils
      pciutils
    ];

  programs = {
    fish = enabled;
    zsh = enabled;
  };
}
