{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) mkOpt;

  cfg = config.godtamnix.services.autoraise;
in {
  options.godtamnix.services.autoraise = {
    enable = lib.mkEnableOption "Focus-follows-mouse via AutoRaise";

    delay = mkOpt lib.types.int 1 "Raise delay in units of pollMillis. 0 = no auto-raise, 1 = quick raise.";
    pollMillis = mkOpt lib.types.int 50 "Mouse poll frequency in ms (minimum 20).";
    warpX = mkOpt (lib.types.nullOr lib.types.float) null "Mouse warp X factor 0..1, or null to disable warp.";
    warpY = mkOpt (lib.types.nullOr lib.types.float) null "Mouse warp Y factor 0..1, or null to disable warp.";
    scale = mkOpt lib.types.float 2.0 "Cursor enlargement multiplier on warp.";
    ignoreApps = mkOpt (lib.types.listOf lib.types.str) [] "App names that should NOT auto-raise (e.g. screen sharing tools).";
    extraArgs = mkOpt (lib.types.listOf lib.types.str) [] "Additional flags passed to AutoRaise verbatim.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.autoraise];

    # Per-user launchd agent: focus-follows-mouse needs to run inside the
    # logged-in user's session so it can talk to the Accessibility APIs.
    #
    # NOTE: macOS Accessibility permission is tied to the binary's absolute
    # path. Because pkgs.autoraise lives under /nix/store/<hash>-..., every
    # nixpkgs bump produces a new path and you'll have to re-tick AutoRaise
    # in System Settings → Privacy & Security → Accessibility.
    launchd.user.agents.autoraise = {
      command = lib.concatStringsSep " " (
        [
          "${pkgs.autoraise}/bin/autoraise"
          "-pollMillis"
          (toString cfg.pollMillis)
          "-delay"
          (toString cfg.delay)
          "-scale"
          (toString cfg.scale)
        ]
        ++ lib.optionals (cfg.warpX != null) ["-warpX" (toString cfg.warpX)]
        ++ lib.optionals (cfg.warpY != null) ["-warpY" (toString cfg.warpY)]
        ++ lib.optionals (cfg.ignoreApps != []) [
          "-ignoreApps"
          (lib.concatStringsSep "," cfg.ignoreApps)
        ]
        ++ cfg.extraArgs
      );

      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
        StandardOutPath = "/tmp/autoraise.out.log";
        StandardErrorPath = "/tmp/autoraise.err.log";
      };
    };
  };
}
