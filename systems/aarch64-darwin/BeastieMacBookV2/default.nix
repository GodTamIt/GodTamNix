{
  lib,
  inputs,
  ...
}: let
  inherit (lib.godtamnix) disabled enabled;
in {
  imports = [
    ./sops.nix
    ./users.nix
    inputs.paneru.darwinModules.paneru
  ];

  godtamnix = {
    nix = enabled;
    system = {
      enable = true;
      fonts = enabled;
    };

    # NOTE: disabled 2026-07-17. The upstream nixpkgs autoraise (v5.3) fails
    # to link on aarch64-darwin: cctools' ld64-957.1 crashes with
    # `Trace/BPT trap: 5` (exit 133) during the link step. Bumping to v5.6
    # avoids the deprecation warning but still hits the same ld crash.
    # Re-enable once nixpkgs ships a cctools/ld64 that links autoraise
    # cleanly, or upstream autoraise drops the SkyLight private framework
    # dependency that triggers the failing link path.
    services.autoraise = disabled;

    suites.media = enabled;

    programs = {
      windscribe = enabled;
      affinity = enabled;
    };

    tools.homebrew = {
      enable = true;
      masEnable = true;

      casks = [];
      brews = [];

      # App Store apps — requires being signed in to the App Store before
      # `darwin-rebuild switch` runs `brew bundle`. App IDs come from
      # https://apps.apple.com/<lang>/app/<slug>/id<NUMERIC-ID>
      masApps = {
        Amphetamine = 937984704;
      };
    };
  };

  networking = {
    hostName = "BeastieMacBookV2";
    computerName = "BeastieMacBookV2";
    localHostName = "BeastieMacBookV2";
  };

  time.timeZone = "America/New_York";

  # Paneru — scrollable/strip tiling WM (Niri/PaperWM paradigm), replacing
  # AeroSpace's BSP grid. Bindings are ported from the niri config in
  # homes/users/godtamit/niri-config.kdl, adapted to paneru's action set.
  # niri "Mod" (Super) → "ctrl" on macOS. Cmd/Option are avoided: Cmd is heavily
  # used by macOS apps (Cmd+Arrow = browser back/forward, text navigation),
  # and Option enters special characters while typing. Ctrl is the least
  # contested global-modifier on macOS.
  #
  # Binding string format (per paneru's parser): "<mods> - <key>" where mods
  # are "+ "-joined (e.g. "ctrl+shift - h"). Arrow keys are "leftarrow"/
  # "rightarrow"/"uparrow"/"downarrow" (not "left"). Brackets are
  # "leftbracket"/"rightbracket" (layout-independent; literal "["/"]" is
  # US-layout-only via UCKeyTranslate lookup).
  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        # Match niri's preset-column-widths (0.33333 / 0.5 / 0.66667).
        preset_column_widths = [0.33333 0.5 0.66667];
      };

      padding = {
        # Match niri layout.gaps (5px outer; paneru has no inner gap concept —
        # windows are laid out edge-to-edge on the strip).
        top = 5;
        bottom = 5;
        left = 5;
        right = 5;
      };

      # ─── Key bindings (ported from niri-config.kdl `binds`) ──────────────
      # niri action                → paneru action          (binding)
      # focus-column-left          → window_focus_west      (Mod+Left)
      # focus-column-right         → window_focus_east      (Mod+Right)
      # focus-workspace-up         → window_focus_north     (Mod+Up)
      # focus-workspace-down       → window_focus_south     (Mod+Down)
      # move-column-left           → window_swap_west       (Mod+Ctrl+Left)
      # move-column-right          → window_swap_east       (Mod+Ctrl+Right)
      # move-window-to-workspace-* → window_virtualmove_*  (Mod+Ctrl+Up/Down)
      # maximize-column            → window_fullwidth       (Mod+M)
      # toggle-window-floating    → window_manage          (Mod+V)
      # switch-preset-column-width → window_resize          (Mod+R)
      # center-column              → window_center          (Mod+C)
      # set-column-width "-10%"    → window_shrink          (Mod+Minus)
      # set-column-width "+10%"    → window_resize          (Mod+Equal)
      # fullscreen-window          → window_fullwidth       (Mod+F) [no true FS]
      #
      # Not ported (no paneru equivalent / macOS-native instead):
      #   - Mod+Q close-window      (macOS cmd+W closes windows natively)
      #   - Mod+Return/T/B/O/Y/D/P app launchers (macOS Spotlight / Raycast)
      #   - Mod+L hyprlock          (macOS lock screen)
      #   - hjkl focus              (Ctrl+H/J/K/L conflict with terminal
      #     readline shortcuts — backspace, kill-line, clear-screen. niri's
      #     config used arrows only, so hjkl is dropped here too.)
      #   - Mod+BracketLeft/Right consume-or-expel (paneru: window_stack/
      #     window_unstack — bound below on Mod+[ / Mod+] for parity)
      #   - Mod+Comma/Period consume/expel (no paneru equivalent)
      #   - Mod+Shift+S/Space/Escape (Wayland-only tools)
      #   - screenshot binds (macOS cmd+Shift+3/4 native)
      # NOTE: paneru's bindings map is action → binding-string (NOT the
      # reverse). The Rust parser iterates `for (command, bindings) in
      # config.bindings`, so the *key* is the command name and the *value*
      # is the keybinding (or a list of keybindings for multiple binds).
      bindings = {
        # Focus — arrows (match niri Mod+Arrow).
        window_focus_west = "ctrl - leftarrow";
        window_focus_east = "ctrl - rightarrow";
        window_focus_north = "ctrl - uparrow";
        window_focus_south = "ctrl - downarrow";

        # Move/swap windows — Ctrl+Option+arrow (niri Mod+Ctrl+Arrow; using
        # Option instead of Shift keeps it distinct from macOS Ctrl+Arrow Space
        # navigation and Ctrl+Shift+Arrow text selection).
        window_swap_west = "ctrl+alt - leftarrow";
        window_swap_east = "ctrl+alt - rightarrow";
        # niri Mod+Ctrl+Up/Down = move-window-to-workspace-up/down.
        # Paneru's virtual workspaces are the row analog; move + follow.
        window_virtualmove_north = "ctrl+alt - uparrow";
        window_virtualmove_south = "ctrl+alt - downarrow";

        # Width / layout (mirror niri binds). `window_resize` has two binds
        # (preset-cycle + grow-by-10%), so it's a list per paneru's OneOrMore.
        window_resize = ["ctrl - r" "ctrl - equal"]; # niri switch-preset / "+10%"
        window_shrink = "ctrl - minus"; # niri set-column-width "-10%"
        window_center = "ctrl - c"; # niri center-column
        # niri maximize-column + fullscreen-window both → full width.
        window_fullwidth = ["ctrl - m" "ctrl - f"];

        # Floating / stacking.
        window_manage = "ctrl - v"; # niri toggle-window-floating
        # niri consume-or-expel-window-left/right (Mod+[ / Mod+]) → paneru
        # stack/unstack into the column to the left.
        # Use the static key names `leftbracket`/`rightbracket` (layout-
        # independent) rather than literal `[`/`]` (US-layout-only).
        window_stack = "ctrl - leftbracket";
        window_unstack = "ctrl - rightbracket";
        window_equalize = "ctrl+shift - leftbracket"; # even out a stack's heights

        # Jump to strip ends (niri has no direct equivalent, but handy).
        window_focus_first = "ctrl - home";
        window_focus_last = "ctrl - end";

        # Move window to next display + follow (niri Mod+Ctrl+Alt+Left/Right).
        window_nextdisplay = ["ctrl+shift+alt - leftarrow" "ctrl+shift+alt - rightarrow"];

        # Quit paneru itself (NOT window close — that's cmd+W on macOS).
        quit = "ctrl+shift+alt - q";
      };
    };
  };
}
