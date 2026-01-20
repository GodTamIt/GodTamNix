{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.suites.multimedia;
in {
  options.godtamnix.suites.multimedia = {
    enable = lib.mkEnableOption "common multimedia configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      imagemagick
      plex-desktop
      vlc
      ytmdesktop
    ];
  };
}
