{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) enabled;

  cfg = config.godtamnix.suites.gaming;
in {
  options.godtamnix.suites.gaming = {
    enable = lib.mkEnableOption "common gaming configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bottles
      # heroic
      # lutris
      # prismlauncher
      # protonup-ng
      # protonup-qt
      # umu-launcher
      # wowup-cf
    ];

    godtamnix = {
      programs = {
        graphical.tools.mangohud = lib.mkDefault enabled;

        terminal = {
          tools = {
            wine = lib.mkDefault enabled;
          };
        };
      };
    };
  };
}
