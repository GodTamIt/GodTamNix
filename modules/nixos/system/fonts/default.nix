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
    # environment.systemPackages =
    #   with pkgs;
    #   (lib.optionals (!config.godtamnix.archetypes.wsl.enable or false) [
    #     font-manager
    #     fontpreview
    #     smile
    #   ]);

    fonts = {
      packages = cfg.fonts;
      enableDefaultPackages = true;

      fontconfig = {
        # allowType1 = true;
        # Defaults to true, but be explicit
        antialias = true;
        hinting.enable = true;

        defaultFonts = let
          common = [
            "Source Sans 3"
            "Cascadia Code"
            "Symbols Nerd Font"
            "Noto Color Emoji"
          ];
        in
          lib.mapAttrs (_: fonts: fonts ++ common) {
            serif = ["Source Serif 4"];
            sansSerif = ["Source Sans 3"];
            emoji = ["Noto Color Emoji"];
            monospace = ["Cascadia Code NF"];
          };
      };

      fontDir = {
        enable = true;
        decompressFonts = true;
      };
    };
  };
}
