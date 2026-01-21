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

      # Fonts
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
      monaspace
      nerd-fonts.monaspace
      font-awesome
      font-manager
      noto-fonts
    ];
  };
}
