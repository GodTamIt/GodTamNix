{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    types
    ;

  # Use direct mkOpt implementation to avoid circular dependency
  mkOpt = type: default: description:
    lib.mkOption {inherit type default description;};

  cfg = config.godtamnix.theme.stylix;
in {
  options.godtamnix.theme.stylix = {
    enable = mkEnableOption "stylix theme for applications";
    theme = mkOpt types.str "catppuccin-mocha" "base16 theme file name";

    cursor = {
      name = mkOpt types.str "catppuccin-mocha-mauve-cursors" "The name of the cursor theme to apply.";
      package = mkOpt types.package (
        if pkgs.stdenv.hostPlatform.isLinux
        then pkgs.catppuccin-cursors.mochaMauve
        else pkgs.emptyDirectory
      ) "The package to use for the cursor theme.";
      size = mkOpt types.int 32 "The size of the cursor.";
    };

    icon = {
      name = mkOpt types.str "Papirus-Dark" "The name of the icon theme to apply.";
      package = mkOpt types.package (pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
        flavor = "mocha";
      }) "The package to use for the icon theme.";
    };
  };

  config = mkIf cfg.enable (
    lib.optionalAttrs (options ? stylix) {
      home = mkIf (pkgs.stdenv.hostPlatform.isLinux && !config.godtamnix.theme.catppuccin.enable) {
        pointerCursor = {
          inherit (cfg.cursor) name package size;
        };
      };

      gtk.gtk3 = mkIf (pkgs.stdenv.hostPlatform.isLinux && !config.godtamnix.theme.catppuccin.enable) {
        font = null;
      };

      stylix = {
        enable = true;
        # autoEnable = false;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";

        cursor = lib.mkOptionDefault cfg.cursor;

        fonts = {
          sizes = {
            desktop = 11;
            applications = 11;
            terminal = 9;
            popups = 11;
          };

          serif = {
            package = pkgs.source-serif;
            name = "Source Serif 4";
          };
          sansSerif = {
            package = pkgs.source-sans;
            name = "Source Sans 3";
          };
          monospace = {
            package = pkgs.cascadia-code;
            name = "Cascadia Code NF";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };

        icons = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          enable = true;
          inherit (cfg.icon) package;
          dark = cfg.icon.name;
          # TODO: support custom light
          light = cfg.icon.name;
        };

        polarity = "dark";

        opacity = {
          desktop = 1.0;
          applications = 0.90;
          terminal = 0.90;
          popups = 1.0;
        };

        targets =
          {
            # Set profile names for firefox
            firefox.profileNames = [config.godtamnix.user.name];

            # TODO: Very custom styling, integrate with their variables
            # Currently setup only for catppuccin/nix
            vscode.enable = false;

            # Disable targets when catppuccin is enabled
            alacritty.enable = !config.godtamnix.theme.catppuccin.enable;
            bat.enable = !config.godtamnix.theme.catppuccin.enable;
            btop.enable = !config.godtamnix.theme.catppuccin.enable;
            cava.enable = !config.godtamnix.theme.catppuccin.enable;
            fish.enable = !config.godtamnix.theme.catppuccin.enable;
            foot.enable = !config.godtamnix.theme.catppuccin.enable;
            fzf.enable = !config.godtamnix.theme.catppuccin.enable;
            ghostty.enable = !config.godtamnix.theme.catppuccin.enable;
            gitui.enable = !config.godtamnix.theme.catppuccin.enable;
            helix.enable = !config.godtamnix.theme.catppuccin.enable;
            k9s.enable = !config.godtamnix.theme.catppuccin.enable;
            kitty = {
              enable = !config.godtamnix.theme.catppuccin.enable;
            };
            lazygit.enable = !config.godtamnix.theme.catppuccin.enable;
            ncspot.enable = !config.godtamnix.theme.catppuccin.enable;
            neovim.enable = !config.godtamnix.theme.catppuccin.enable;
            tmux.enable = !config.godtamnix.theme.catppuccin.enable;
            vesktop.enable = !config.godtamnix.theme.catppuccin.enable;
            vicinae.enable = !config.godtamnix.theme.catppuccin.enable;
            yazi.enable = !config.godtamnix.theme.catppuccin.enable;
            zathura.enable = !config.godtamnix.theme.catppuccin.enable;
            zellij.enable = !config.godtamnix.theme.catppuccin.enable;
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            gnome.enable = !config.godtamnix.theme.catppuccin.enable;
            # FIXME: not working
            gtk.enable = false;
            hyprland.enable = !config.godtamnix.theme.catppuccin.enable;
            # FIXME:: upstream needs module fix
            hyprlock.useWallpaper = false;
            hyprlock.enable = false;
            qt.enable = !config.godtamnix.theme.catppuccin.enable;
            sway.enable = !config.godtamnix.theme.catppuccin.enable;
            # TODO: Very custom styling, integrate with their variables
            # Currently setup only for catppuccin/nix
            swaync.enable = false;
            waybar.enable = !config.godtamnix.theme.catppuccin.enable;
          };
      };
    }
  );
}
