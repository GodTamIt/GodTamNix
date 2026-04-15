{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.godtamnix.system.desktop.kde;
in {
  options.godtamnix.system.desktop.kde.enable = mkEnableOption "KDE Plasma";

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    environment.systemPackages = with pkgs.kdePackages; [
      kcalc # Calculator
      kolourpaint # Simple paint program
      partitionmanager # Disk management
      sddm-kcm # SDDM configuration module
    ];
  };
}
