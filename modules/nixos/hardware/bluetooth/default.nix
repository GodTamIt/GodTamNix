{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.hardware.bluetooth;
in {
  options.godtamnix.hardware.bluetooth = {
    enable = lib.mkEnableOption "support for bluetooth stack";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    environment.systemPackages = with pkgs; [
      bluetui
    ];
  };
}
