{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  godtamnix = {
    user = {
      enable = true;
      name = "jlh";
      fullName = "Lance Hasson";
    };

    nix = enabled;
  };

  programs = {
    fish = {
      enable = true;

      loginShellInit = ''
        set -x NIX_PATH nixpkgs=channel:nixos-unstable
        set -x NIX_LOG info
        set -x TERMINAL kitty
      '';

      interactiveShellInit = ''
        set -x fish_greeting
        fastfetch
      '';

      shellAbbrs = {
        ".." = "cd ..";
        "..." = "cd ../..";
        ls = "eza";
        grep = "rg";
        ps = "procs";
      };
    };

    git = {
      enable = true;

      settings = {
        push.autoSetupRemote = true;
      };
    };

    starship = {
      enable = true;

      enableFishIntegration = true;
      enableInteractive = true;

      settings = fromTOML (builtins.readFile ./starship.toml);
    };
  };

  home.packages = with pkgs; [
    fastfetch
  ];
}
