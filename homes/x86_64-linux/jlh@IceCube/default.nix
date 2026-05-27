{lib, ...}: let
  inherit (lib.godtamnix) enabled;
in {
  imports = [
    ../../users/jlh
  ];

  godtamnix = {
    theme = {
      catppuccin = enabled;
      gtk = {
        enable = true;
        usePortal = true;
      };
      qt = enabled;
      stylix = enabled;
    };

    suites = {
      development = {
        enable = true;
        aiEnable = true;
        nixEnable = true;
      };
    };
  };

  home.stateVersion = "25.11";
}
