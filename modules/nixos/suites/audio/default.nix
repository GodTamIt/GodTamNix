{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) enabled;

  cfg = config.godtamnix.suites.audio;
in
{
  options.godtamnix.suites.audio = {
    enable = lib.mkEnableOption "common system audio configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      easyeffects
      playerctl
      wireplumber
    ];

    # Allow realtime scheduling priority for user processes.
    security.rtkit = enabled;

    services = {
      pipewire = {
        enable = true;

        alsa.enable = true;
        alsa.support32Bit = true;

        jack.enable = true;

        pulse.enable = true;
      };
    };
  };
}
