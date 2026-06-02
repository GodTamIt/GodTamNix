{
  config,
  lib,
  inputs,
  system,
  ...
}:
with lib; let
  cfg = config.godtamnix.programs.graphical.bars.noctalia;

  # noctalia is a Wayland shell and the flake exposes no darwin package, so the
  # upstream module (which declares `programs.noctalia`) is only imported on
  # Linux. The config block below is gated on the same condition so it never
  # references the undeclared option on darwin.
  isLinux = hasSuffix "linux" system;
in {
  imports = optionals isLinux [
    inputs.noctalia.homeModules.default
  ];

  options.godtamnix.programs.graphical.bars.noctalia = {
    enable = mkEnableOption "Noctalia, a Quickshell-based Wayland shell/bar";

    autostart = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Start noctalia from a systemd user service bound to the graphical
        session target. This is the same mechanism waybar uses to come up under
        niri/Hyprland, so no compositor `spawn-at-startup` line is needed.
      '';
    };

    settings = mkOption {
      type = types.attrs;
      default = {
        # Match the rest of the system: catppuccin mocha + Fira Code Nerd Font.
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
        shell = {
          font = "FiraCode Nerd Font";
        };
      };
      description = ''
        Declarative noctalia settings, rendered to a read-only
        ~/.config/noctalia/config.toml (a Nix store symlink). Because the file is
        read-only, changes made in noctalia's in-app settings menu will not
        persist across a restart — adjust them here instead. Set to `{}` to skip
        managing the file and let noctalia own its own config at runtime.
      '';
    };
  };

  # optionalAttrs (not mkIf) so the `programs.noctalia` path is structurally
  # absent on darwin — a mkIf-false definition would still trip the module
  # system's "option does not exist" check there.
  config = mkIf cfg.enable (optionalAttrs isLinux {
    programs.noctalia = {
      enable = true;
      systemd.enable = cfg.autostart;
      inherit (cfg) settings;
    };
  });
}
