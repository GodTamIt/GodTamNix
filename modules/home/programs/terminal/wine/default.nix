{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.godtamnix.programs.terminal.tools.wine;
in {
  options.godtamnix.programs.terminal.tools.wine = {
    enable = lib.mkEnableOption "Wine";

    wayland = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install packages optimized for Wayland";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        winetricks
      ]
      ++ lib.optionals cfg.wayland [
        wineWowPackages.waylandFull
      ]
      ++ lib.optionals (!cfg.wayland) [
        wineWowPackages.unstableFull
      ];
  };
}
