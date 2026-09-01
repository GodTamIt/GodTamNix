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

    programs = {
      terminal.ai = {
        pi = {
          enable = true;
          settings = builtins.fromJSON (builtins.readFile ./pi/settings.json);
          mcp = builtins.fromJSON (builtins.readFile ./pi/mcp.json);
          keybindings = builtins.fromJSON (builtins.readFile ./pi/keybindings.json);
          models = builtins.fromJSON (builtins.readFile ./pi/models.json);
          agentsDir = ./pi/agents;
          skillsDir = ./pi/skills;
        };
      };
    };

    nix = enabled;
  };

  home.file.".pi/agent/agent-roster.json".source = ./pi/agent-roster.json;

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
