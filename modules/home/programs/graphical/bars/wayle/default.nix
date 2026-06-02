{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.godtamnix.programs.graphical.bars.wayle;
in {
  # `services.wayle` is a built-in home-manager module (no flake input needed,
  # unlike noctalia). It is declared on every platform but asserts Linux at eval
  # time when enabled, so this wrapper just forwards to it — no upstream import
  # or platform gating is required here. Enabling it brings wayle up via its own
  # systemd user service on the graphical session (same mechanism as waybar /
  # noctalia), so no compositor spawn-at-startup line is needed.
  options.godtamnix.programs.graphical.bars.wayle = {
    enable = mkEnableOption "Wayle, a compositor-agnostic Wayland shell/bar (bar + notifications + OSD)";

    settings = mkOption {
      type = types.attrs;
      default = {};
      example = literalExpression ''
        {
          styling = {
            theme-provider = "wayle";
            palette = {
              bg = "#1e1e2e"; # Catppuccin Mocha base
              fg = "#cdd6f4"; # Catppuccin Mocha text
              primary = "#cba6f7"; # Catppuccin Mocha mauve
            };
          };
          bar = {
            scale = 1;
            location = "top";
            rounding = "sm";
            layout = [
              {
                monitor = "*";
                left = ["clock"];
                center = ["media"];
                right = ["battery"];
              }
            ];
          };
          modules.clock = {
            format = "%H:%M";
            icon-show = true;
            label-show = true;
          };
        }
      '';
      description = ''
        Declarative wayle settings, rendered to ~/.config/wayle/config.toml.

        Left empty by default: wayle then owns its own writable config.toml at
        runtime, so it can be configured live via the `wayle-settings` GUI or the
        `wayle config` CLI and translated back here afterwards — the same
        workflow used to bring up noctalia.

        Setting this to a non-empty attrset makes home-manager generate
        config.toml as a read-only Nix store symlink; while it is managed this
        way, changes made through the GUI/CLI will not persist across a restart.
        See `example` for a Catppuccin Mocha starting point.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.wayle = {
      enable = true;
      inherit (cfg) settings;
    };
  };
}
