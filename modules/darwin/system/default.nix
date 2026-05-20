{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.system;
in {
  options.godtamnix.system = {
    enable = lib.mkEnableOption "macOS system defaults";
  };

  config = mkIf cfg.enable {
    system = {
      defaults = {
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleShowAllExtensions = true;
          AppleShowScrollBars = "Always";

          # Fast key repeat for vim-style nav
          InitialKeyRepeat = 15;
          KeyRepeat = 2;

          # Disable macOS text "smart" replacements that break code typing
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;

          # Disable press-and-hold for accent menu so vim hjkl repeats
          ApplePressAndHoldEnabled = false;
        };

        dock = {
          autohide = true;
          show-recents = false;
          mru-spaces = false;
          tilesize = 36;
          minimize-to-application = true;
          # Aerospace + macOS Spaces don't play well with animations
          expose-animation-duration = 0.1;
        };

        finder = {
          AppleShowAllFiles = true;
          AppleShowAllExtensions = true;
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "clmv"; # column view
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXShowPosixPathInTitle = true;
        };

        loginwindow = {
          GuestEnabled = false;
        };

        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
        };

        # Disable the chime on boot
        # NOTE: Available on macOS 12+
        # NvramVariables.StartupMute = true;
      };

      # Disable the macOS Mission Control "Move left/right a space" shortcuts
      # (Ctrl+Left, Ctrl+Right and shift variants) so AeroSpace's Ctrl+Arrow
      # bindings for workspace navigation aren't intercepted by macOS.
      #
      # Symbolic hotkey IDs:
      #   79  = Move left a space        (Ctrl+Left)
      #   80  = Move left a space, shift (Ctrl+Shift+Left)
      #   81  = Move right a space       (Ctrl+Right)
      #   82  = Move right a space, shift(Ctrl+Shift+Right)
      #
      # macOS needs a logout/login (or `killall Dock; killall SystemUIServer`)
      # for symbolic hotkey changes to take effect.
      defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "79".enabled = false;
          "80".enabled = false;
          "81".enabled = false;
          "82".enabled = false;
        };
      };

      # macOS state version — bump only if upstream nix-darwin docs say so
      stateVersion = 6;

      # Required by recent nix-darwin for user-scoped defaults
      # primaryUser is set by godtamnix.users in modules/darwin/users
    };
  };
}
