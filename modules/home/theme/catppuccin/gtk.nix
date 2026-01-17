{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.godtamnix.theme.catppuccin;
in {
  config = lib.mkIf cfg.enable {
    godtamnix = {
      theme = {
        gtk = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          cursor = {
            name = "catppuccin-mocha-mauve-cursors";
            package = pkgs.catppuccin-cursors.mochaMauve;
            size = 32;
          };

          icon = {
            name = "Papirus-Dark";
            package = pkgs.catppuccin-papirus-folders.override {
              accent = "mauve";
              flavor = "mocha";
            };
          };

          theme = {
            name = "catppuccin-mocha-blue-standard";
            package = pkgs.catppuccin-gtk.override {
              accents = ["mauve"];
              variant = "mocha";
            };
          };
        };
      };
    };
  };
}
