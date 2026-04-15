{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.godtamnix.programs.graphical.desktop.kde;
in {
  options.godtamnix.programs.graphical.desktop.kde = {
    enable = mkEnableOption "KDE Plasma declarative configuration";
    overrideConfig = mkOption {
      type = types.bool;
      default = true;
      description = "If true, home-manager fully manages KDE configs overriding manual changes. Set to false to only set defaults and allow manual configuration.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf config.godtamnix.theme.catppuccin.enable [
      (pkgs.catppuccin-kde.override {
        flavour = [config.godtamnix.theme.catppuccin.flavor];
        accents = [config.godtamnix.theme.catppuccin.accent];
      })
    ];

    programs.plasma = {
      enable = true;
      inherit (cfg) overrideConfig;

      workspace = {
        clickItemTo = "select";
        lookAndFeel = mkIf config.godtamnix.theme.catppuccin.enable "Catppuccin-${lib.godtamnix.capitalize config.godtamnix.theme.catppuccin.flavor}-${lib.godtamnix.capitalize config.godtamnix.theme.catppuccin.accent}";
      };

      kwin = {
        effects = {
          wobblyWindows.enable = true;
          blur.enable = true;
        };
      };

      panels = [
        {
          location = "bottom";
          widgets = [
            # We can leave this empty or with default widgets. If overrideConfig is false, they probably want to configure this themselves anyway.
            "org.kde.plasma.kickoff"
            "org.kde.plasma.icontasks"
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
          ];
        }
      ];
    };
  };
}
