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
    # This gets the basic nix options setup.
    nix = enabled;

    # Create the user account.
    user = {
      enable = true;
      name = "godtamit";
      fullName = "Christopher Tam";
      email = lib.godtamnix.decode "b2hnb2R0YW1pdEBnbWFpbC5jb20=";
    };

    suites = {
      development = {
        enable = true;
        awsEnable = true;
        digitaloceanEnable = true;
        dockerEnable = true;
        kubernetesEnable = true;
        nixEnable = true;
        sqlEnable = true;
        aiEnable = true;
      };

      gaming = enabled;
      multimedia = enabled;

      video = {
        enable = true;
        kdenliveEnable = true;
        obsEnable = true;
      };
    };

    theme = {
      catppuccin = enabled;
      gtk = {
        enable = true;
        usePortal = true;
      };
      qt = enabled;
      stylix = enabled;
    };

    programs = {
      graphical = {
        browsers = {
          google-chrome = enabled;
        };
      };
    };
  };

  services = {
    udiskie = {
      enable = true;
      automount = true;
    };
  };

  home = {
    packages = with pkgs; [
      onlyoffice-desktopeditors
    ];

    sessionVariables = {
      BROWSER = "firefox";
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      config.common.default = "*";
    };

    mimeApps = {
      enable = true;

      # defaultApplications = {
      #   "text/html" = "firefox.desktop";
      #   "x-scheme-handler/http" = "firefox.desktop";
      #   "x-scheme-handler/https" = "firefox.desktop";
      #   "x-scheme-handler/about" = "firefox.desktop";
      #   "x-scheme-handler/unknown" = "firefox.desktop";
      #   "application/xhtml+xml" = "firefox.desktop";
      #   "application/x-extension-htm" = "firefox.desktop";
      #   "application/x-extension-html" = "firefox.desktop";
      #   "application/x-extension-shtml" = "firefox.desktop";
      #   "application/x-extension-xhtml" = "firefox.desktop";
      #   "application/x-extension-xht" = "firefox.desktop";
      # };
    };
  };

  home.stateVersion = "25.11";
}
