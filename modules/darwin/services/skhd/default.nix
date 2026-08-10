{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) mkOpt;

  cfg = config.godtamnix.services.skhd;
in {
  options.godtamnix.services.skhd = {
    enable = lib.mkEnableOption "skhd hotkey daemon";

    # Binding map is `key-combo → shell-command`. skhd's config syntax is
    # `<key-combo> : <command>`; an attrset keeps it declarative and lets us
    # render the config file in the nix store (no per-user dotfile drift).
    bindings = mkOpt (lib.types.attrsOf lib.types.str) {} ''
      skhd bindings as an attrset of `key-combo → shell-command`.
      Key combos use skhd syntax, e.g. `"ctrl - t"` or `"cmd + shift - h"`.
    '';
  };

  config = mkIf cfg.enable {
    # Per-user launchd agent: skhd needs an event tap in the logged-in
    # user's session to receive global hotkeys.
    #
    # NOTE: macOS Accessibility permission is tied to the binary's absolute
    # path. Because pkgs.skhd lives under /nix/store/<hash>-..., every
    # nixpkgs bump produces a new path and you'll have to re-tick skhd in
    # System Settings → Privacy & Security → Accessibility.
    launchd.user.agents.skhd = {
      command = let
        configFile =
          pkgs.writeText "skhdrc" (lib.concatStringsSep "\n"
            (lib.mapAttrsToList (key: cmd: "${key} : ${cmd}") cfg.bindings));
      in "${pkgs.skhd}/bin/skhd -c ${configFile}";

      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
        StandardOutPath = "/tmp/skhd.out.log";
        StandardErrorPath = "/tmp/skhd.err.log";
      };
    };
  };
}
