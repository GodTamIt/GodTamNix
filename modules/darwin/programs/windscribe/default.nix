{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.programs.windscribe;
in {
  options.godtamnix.programs.windscribe = {
    enable = lib.mkEnableOption "Windscribe VPN (Homebrew cask — not in nixpkgs for Darwin)";
  };

  config = mkIf cfg.enable {
    # Depends on godtamnix.tools.homebrew.enable; harmless no-op otherwise.
    godtamnix.tools.homebrew.casks = ["windscribe"];
  };
}
