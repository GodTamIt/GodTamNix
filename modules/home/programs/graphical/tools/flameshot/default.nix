{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.godtamnix.programs.graphical.tools.flameshot;
in {
  options.godtamnix.programs.graphical.tools.flameshot = {
    enable = mkEnableOption "flameshot";
  };

  config = mkIf cfg.enable {
    services.flameshot = {
      enable = true;
      settings = {
        General = {
          useJpgForClipboard = true;
          useGrimAdapter = true;
        };
      };
    };
  };
}
