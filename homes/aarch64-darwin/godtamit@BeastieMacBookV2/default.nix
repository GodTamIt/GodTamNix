{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  imports = [
    ../../users/godtamit
  ];

  godtamnix = {
    suites = {
      development = {
        enable = true;
        awsEnable = true;
        digitaloceanEnable = true;
        dockerEnable = true;
        kubernetesEnable = true;
        nixEnable = true;
        rustEnable = true;
        sqlEnable = true;
        aiEnable = true;
      };

      multimedia = enabled;
    };

    theme = {
      catppuccin = enabled;
      stylix = enabled;
    };

    programs = {
      graphical = {
        browsers = {
          brave = {
            enable = true;
          };
        };
      };
    };
  };

  programs = {
    kitty.font.size = lib.mkForce 11;
  };

  home = {
    packages = with pkgs; [
      aldente
      antigravity
      bitwarden-desktop
      google-chrome
    ];

    sessionVariables = {
      BROWSER = "open";
    };
  };

  home.stateVersion = "25.11";
}
