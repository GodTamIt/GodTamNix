{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.godtamnix.system.printing;
in {
  options.godtamnix.system.printing = {
    enable = mkEnableOption "printing system configuration";
    networking = mkOption {
      type = types.bool;
      default = true;
      description = "Enable network printing support (Avahi).";
    };
  };

  config = mkIf cfg.enable {
    services.printing.enable = true;

    services.avahi = mkIf cfg.networking {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
