{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.suites.video;
in {
  options.godtamnix.suites.video = {
    enable = lib.mkEnableOption "common video manipulation configuration";
    kdenliveEnable = lib.mkEnableOption "Kdenlive video editing";
    obsEnable = lib.mkEnableOption "Open Broadcaster Software";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        ffmpeg_7-full
        handbrake
        mkvtoolnix
        yt-dlp
      ]
      ++ lib.optionals cfg.kdenliveEnable [kdePackages.kdenlive]
      ++ lib.optionals cfg.obsEnable [obs-studio];
  };
}
