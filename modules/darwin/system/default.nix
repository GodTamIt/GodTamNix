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
          tilesize = 64;
          minimize-to-application = true;
          # Aerospace + macOS Spaces don't play well with animations
          expose-animation-duration = 0.1;

          # NOTE: persistent-apps REPLACES the dock contents; it doesn't append.
          # Home-manager apps go via ~/Applications/Home Manager Apps (created
          # by mac-app-util). Homebrew casks land in /Applications/<Name>.app
          # only after the first rebuild that installs the cask, so those dock
          # entries will show a "?" until then.
          persistent-apps = let
            inherit (config.users.users.${config.system.primaryUser}) home;
            hmApps = "${home}/Applications/Home Manager Apps";
          in [
            "${hmApps}/kitty.app"
            "${hmApps}/Firefox.app"
            "${hmApps}/Brave Browser.app"
            "${hmApps}/Zed.app"
            "${hmApps}/Discord.app"
            "${hmApps}/Signal.app"
            "/Applications/Plex.app"
          ];
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

      # Menu bar icons (Control Center modules). The `NSStatusItem Visible …`
      # keys control whether the icon appears in the menu bar; the bare module
      # keys control Control Center visibility (2 = menu bar + CC, 8 = CC only,
      # 24 = hidden). A `killall ControlCenter` is needed for changes to apply.
      defaults.CustomUserPreferences."com.apple.controlcenter" = {
        "NSStatusItem Visible WiFi" = true;
        "NSStatusItem Visible Bluetooth" = true;
        "NSStatusItem Visible Battery" = false;
        "NSStatusItem Visible BatteryShowPercentage" = false;
        "NSStatusItem Visible NowPlaying" = false;
        "NSStatusItem Visible Spotlight" = false;
        WiFi = 2;
        Bluetooth = 2;
        Battery = 8;
        NowPlaying = 8;
        Spotlight = 24;
      };

      # Menu bar clock: show date + seconds.
      defaults.CustomUserPreferences."com.apple.menuextra.clock" = {
        ShowDate = 1;
        ShowSeconds = true;
        IsAnalog = false;
      };

      # macOS state version — bump only if upstream nix-darwin docs say so
      stateVersion = 6;

      # Required by recent nix-darwin for user-scoped defaults
      # primaryUser is set by godtamnix.users in modules/darwin/users
    };
  };
}
