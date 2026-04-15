{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.godtamnix.system.display-manager;
in {
  options.godtamnix.system.display-manager = {
    sddm = {
      enable = mkEnableOption "SDDM";
      catppuccin = {
        enable = mkEnableOption "Catppuccin theme for SDDM";
        flavor = mkOption {
          type = types.str;
          default = "mocha";
          description = "Catppuccin flavor for SDDM";
        };
      };
    };
    gdm = {
      enable = mkEnableOption "GDM";
    };
  };

  config = mkMerge [
    (mkIf cfg.sddm.enable {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      catppuccin = mkIf cfg.sddm.catppuccin.enable {
        enable = true;
        sddm = {
          enable = true;
          inherit (cfg.sddm.catppuccin) flavor;
          font = "Noto Sans";
          fontSize = "9";
        };
      };
    })

    (mkIf cfg.gdm.enable {
      services.xserver.displayManager.gdm.enable = true;
    })
  ];
}
