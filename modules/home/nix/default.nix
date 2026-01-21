{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.godtamnix.nix;
in {
  options.godtamnix.nix.enable = mkEnableOption "Basic Nix home-manager settings.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mission-center
    ];
  };
}
