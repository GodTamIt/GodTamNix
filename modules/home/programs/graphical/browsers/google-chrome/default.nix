{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.godtamnix.programs.graphical.browsers.google-chrome;
in {
  options.godtamnix.programs.graphical.browsers.google-chrome = {
    enable = lib.mkEnableOption "Google Chrome";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
    ];
  };
}
