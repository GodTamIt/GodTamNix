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
      name = "eddy";
      fullName = lib.godtamnix.decode "RWRkeSBHaGFyYmk=";
      email = lib.godtamnix.decode "ZWRkeS5naGFyYmkuY2FAZ21haWwuY29t";
    };

    nix = enabled;

    programs.terminal.ai.pi = {
      enable = true;
      settings = builtins.fromJSON (builtins.readFile ./pi/settings.json);
      mcp = builtins.fromJSON (builtins.readFile ./pi/mcp.json);
      keybindings = builtins.fromJSON (builtins.readFile ./pi/keybindings.json);
      models = builtins.fromJSON (builtins.readFile ./pi/models.json);
      agentsDir = ./pi/agents;
      skillsDir = ./pi/skills;
    };
  };

  home.file.".pi/agent/agent-roster.json".source = ./pi/agent-roster.json;

  programs = {
    zsh = {
      enable = true;

      initContent = ''
        export NIX_PATH nixpkgs=channel:nixos-unstable
        export NIX_LOG info
        export TERMINAL kitty

        fastfetch
      '';

      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        ls = "eza";
        grep = "rg";
        ps = "procs";

        # k8s aliases
        k = "kubectl";
        kctx = "kubectx";
        kns = "kubens";
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

      enableZshIntegration = true;
      enableInteractive = true;

      settings = fromTOML (builtins.readFile ./starship.toml);
    };
  };

  home.packages = with pkgs; [
    fastfetch
  ];
}
