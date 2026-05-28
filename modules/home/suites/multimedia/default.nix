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
    home.packages = with pkgs;
      [
        imagemagick
        (
          if stdenv.hostPlatform.isDarwin
          then vlc-bin
          else vlc
        )
        ytmdesktop
      ]
      ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64) [
        plex-desktop
      ];
  };
}
