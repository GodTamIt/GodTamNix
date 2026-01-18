{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) enabled;

  cfg = config.godtamnix.suites.gaming;
in {
  options.godtamnix.suites.gaming = {
    enable = lib.mkEnableOption "common system-wide gaming configuration";
  };

  config = mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;

        protontricks = enabled;
        gamescopeSession = enabled;
      };
    };
  };
}
