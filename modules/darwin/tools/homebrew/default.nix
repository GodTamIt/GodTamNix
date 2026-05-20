{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) mkOpt;

  cfg = config.godtamnix.tools.homebrew;
in {
  options.godtamnix.tools.homebrew = {
    enable = lib.mkEnableOption "Homebrew (declarative Brewfile via nix-darwin)";
    masEnable = lib.mkEnableOption "Mac App Store downloads (requires `mas` brew)";

    brews = mkOpt (lib.types.listOf lib.types.str) [] "Homebrew formulae (brews) to install.";
    casks = mkOpt (lib.types.listOf lib.types.str) [] "Homebrew casks to install.";
    taps = mkOpt (lib.types.listOf lib.types.str) [] "Extra taps to add (homebrew/core is always tapped).";
    masApps = mkOpt (lib.types.attrsOf lib.types.int) {} "Mac App Store apps (name → numeric id). Requires masEnable.";
  };

  config = mkIf cfg.enable {
    # https://docs.brew.sh/Manpage#environment
    environment.variables = {
      HOMEBREW_BAT = "1";
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_INSECURE_REDIRECT = "1";
    };

    # Apple Silicon brew prefix. The nix-darwin homebrew module + shell
    # integrations (Fish/Bash/Zsh enable* below) handle interactive PATH,
    # but launchd-spawned processes and `system(3)` callers need this too.
    environment.systemPath = ["/opt/homebrew/bin"];

    homebrew = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      global = {
        brewfile = true;
        autoUpdate = false;
      };

      # Update casks even when versions only differ in metadata
      caskArgs.appdir = "/Applications";

      onActivation = {
        # Conservative defaults — flip to true once you trust the Brewfile.
        autoUpdate = false;
        upgrade = false;
        # "none" preserves any preexisting brew installs. Bump to "uninstall"
        # or "zap" only once the Brewfile fully describes what you want.
        cleanup = "none";
      };

      inherit (cfg) taps;
      brews =
        cfg.brews
        ++ lib.optionals cfg.masEnable ["mas"];
      inherit (cfg) casks;
      masApps = mkIf cfg.masEnable cfg.masApps;
    };
  };
}
