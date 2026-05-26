{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.programs.affinity;
in {
  options.godtamnix.programs.affinity = {
    enable = lib.mkEnableOption "Affinity suite (Homebrew cask — proprietary, requires license)";
  };

  config = mkIf cfg.enable {
    godtamnix.tools.homebrew.casks = ["affinity"];
  };
}
