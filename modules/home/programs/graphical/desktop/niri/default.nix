{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.godtamnix.programs.graphical.desktop.niri;
in {
  options.godtamnix.programs.graphical.desktop.niri.enable = mkEnableOption "niri";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Locking is handled by noctalia (`noctalia msg session lock`, bound to
      # Mod+L in niri-config.kdl), so hyprlock is intentionally not installed.
      hypridle
      gtk3
      # niri integrates xwayland-satellite automatically when it is on PATH
      # (>= 0.7). The niri package itself is installed by the system-level
      # `programs.niri` module.
      xwayland-satellite
    ];
  };
}
