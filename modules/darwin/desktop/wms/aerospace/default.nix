{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) mkOpt;

  cfg = config.godtamnix.desktop.wms.aerospace;
in {
  options.godtamnix.desktop.wms.aerospace = {
    enable = lib.mkEnableOption "AeroSpace tiling window manager";
    mod = mkOpt lib.types.str "cmd" "Primary modifier (cmd = Hyprland-style on macOS, alt for closer Linux Super feel).";
    workspaceCount = mkOpt lib.types.int 9 "Number of workspaces to bind (1..N).";
  };

  config = mkIf cfg.enable {
    services.aerospace = {
      enable = true;
      package = pkgs.aerospace;

      settings = {
        after-startup-command = [];
        # NOTE: do NOT set start-at-login here — nix-darwin's services.aerospace
        # module installs its own LaunchAgent. Setting start-at-login = true
        # would have aerospace install a competing LaunchAgent on first run,
        # and nix-darwin asserts against that.

        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        accordion-padding = 30;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";

        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

        gaps = {
          inner.horizontal = 6;
          inner.vertical = 6;
          outer.left = 6;
          outer.bottom = 6;
          outer.top = 6;
          outer.right = 6;
        };

        # Modifier strategy (with mod = "alt" / "cmd"):
        #   - mod + 1..9                    → workspace N
        #   - mod + Shift + 1..9            → move window to N
        #   - nav + Arrow                   → focus direction (hjkl aliases kept as backup)
        #   - nav + Shift + Arrow           → move window direction
        #   - Ctrl + Left / Right           → workspace prev / next  (requires macOS Spaces shortcuts disabled — see system module)
        #   - Ctrl + Shift + Left / Right   → move window to prev / next workspace
        #   - nav + - / =                   → resize
        #   - nav + f                       → fullscreen
        #
        # `nav` adds alt to `mod` so navigation is a deliberate extra gesture,
        # except when mod is already alt — then nav collapses to just alt
        # (alt+h, alt+arrow, …) since the doubled "alt-alt-…" form is invalid.
        mode.main.binding = let
          mod = cfg.mod;
          shift = "${mod}-shift";
          nav =
            if mod == "alt"
            then mod
            else "${mod}-alt";
          navShift = "${nav}-shift";

          workspaceKeys = builtins.listToAttrs (
            builtins.concatMap (i: let
              n = toString i;
            in [
              {
                name = "${mod}-${n}";
                value = "workspace ${n}";
              }
              {
                name = "${shift}-${n}";
                value = "move-node-to-workspace ${n}";
              }
            ]) (lib.range 1 cfg.workspaceCount)
          );

          arrowFocusKeys = {
            "${nav}-left" = "focus left";
            "${nav}-down" = "focus down";
            "${nav}-up" = "focus up";
            "${nav}-right" = "focus right";

            "${navShift}-left" = "move left";
            "${navShift}-down" = "move down";
            "${navShift}-up" = "move up";
            "${navShift}-right" = "move right";
          };

          hjklFocusKeys = {
            "${nav}-h" = "focus left";
            "${nav}-j" = "focus down";
            "${nav}-k" = "focus up";
            "${nav}-l" = "focus right";

            "${navShift}-h" = "move left";
            "${navShift}-j" = "move down";
            "${navShift}-k" = "move up";
            "${navShift}-l" = "move right";
          };

          workspaceArrowKeys = {
            "ctrl-left" = "workspace prev";
            "ctrl-right" = "workspace next";
            "ctrl-shift-left" = "move-node-to-workspace prev";
            "ctrl-shift-right" = "move-node-to-workspace next";
          };

          miscKeys = {
            "${nav}-minus" = "resize smart -50";
            "${nav}-equal" = "resize smart +50";

            "${nav}-f" = "fullscreen";
            "${nav}-v" = "layout floating tiling";
            "${nav}-e" = "layout tiles horizontal vertical";

            "${mod}-tab" = "workspace-back-and-forth";

            "${shift}-q" = "close";
            "${shift}-c" = "reload-config";
          };
        in
          workspaceKeys
          // arrowFocusKeys
          // hjklFocusKeys
          // workspaceArrowKeys
          // miscKeys;
      };
    };
  };
}
