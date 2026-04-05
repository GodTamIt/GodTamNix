{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.godtamnix.hardware.hid;
in {
  options.godtamnix.hardware.hid = {
    enable = lib.mkEnableOption "support for WebHID hidraw access";
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess"
    '';
  };
}
