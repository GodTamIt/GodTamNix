{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  imports = [
    ./sops.nix
    ./users.nix
  ];

  godtamnix = {
    nix = enabled;
    system = enabled;

    desktop.wms.aerospace = {
      enable = true;
      mod = "alt";
      workspaceCount = 9;
    };

    services.autoraise = enabled;

    suites.media = enabled;

    programs.windscribe = enabled;

    tools.homebrew = {
      enable = true;
      masEnable = true;

      casks = [];
      brews = [];

      # App Store apps — requires being signed in to the App Store before
      # `darwin-rebuild switch` runs `brew bundle`. App IDs come from
      # https://apps.apple.com/<lang>/app/<slug>/id<NUMERIC-ID>
      masApps = {
        Amphetamine = 937984704;
      };
    };
  };

  networking = {
    hostName = "BeastieMacBookV2";
    computerName = "BeastieMacBookV2";
    localHostName = "BeastieMacBookV2";
  };

  time.timeZone = "America/New_York";

  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    noto-fonts
  ];
}
