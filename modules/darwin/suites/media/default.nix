{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) mkOpt;

  cfg = config.godtamnix.suites.media;
in {
  options.godtamnix.suites.media = {
    enable = lib.mkEnableOption "media consumption suite (Plex, etc.)";
    plexEnable = mkOpt lib.types.bool true "Install Plex desktop via Homebrew cask (plex-desktop isn't packaged for Darwin in nixpkgs).";
  };

  config = mkIf cfg.enable {
    # Depends on godtamnix.tools.homebrew.enable being true on the host —
    # the cask list is merged into the existing homebrew module, so if
    # homebrew isn't enabled this is a no-op rather than an error.
    godtamnix.tools.homebrew.casks =
      lib.optionals cfg.plexEnable ["plex"];
  };
}
