{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.godtamnix.programs.graphical.browsers.brave;
in
{
  options.godtamnix.programs.graphical.browsers.brave = {
    enable = lib.mkEnableOption "Brave Browser";

    commandLineArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of command line arguments to pass to Brave";
      default = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    };

    dictionaries = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "List of dictionaries to install";
      default = [
        pkgs.hunspellDictsChromium.en_US
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;

      inherit (cfg) commandLineArgs dictionaries;
    };
  };
}
