{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.system.fonts;
in {
  imports = [(lib.getFile "modules/common/system/fonts/default.nix")];

  config = mkIf cfg.enable {
    fonts.packages = cfg.fonts;

    system.defaults.NSGlobalDomain.AppleFontSmoothing = 1;
  };
}
