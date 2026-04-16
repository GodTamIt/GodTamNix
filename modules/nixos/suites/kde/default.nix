{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.suites.kde;
in {
  options.godtamnix.suites.kde = {
    enable = lib.mkEnableOption "common system-wide KDE configuration";

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        kdePackages.kcalc
        kdePackages.kclock
        kdePackages.kcolorchooser
        kdePackages.ksystemlog
        kdePackages.isoimagewriter
        wl-clipboard
      ];
      description = "Extra packages to install in the KDE environment";
    };

    excludePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        kdePackages.elisa # Music player
        kdePackages.kmahjongg
        kdePackages.kmines
        kdePackages.kpat # Solitaire
        kdePackages.ksudoku
        kdePackages.ktorrent
      ];
      description = "Packages to exclude from the default KDE environment";
    };
  };

  config = mkIf cfg.enable {
    services = {
      desktopManager.plasma6.enable = true;
    };

    environment.systemPackages = cfg.extraPackages;
    environment.plasma6.excludePackages = cfg.excludePackages;
  };
}
