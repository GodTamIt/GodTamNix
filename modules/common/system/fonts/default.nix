{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.godtamnix) mkOpt;

  cfg = config.godtamnix.system.fonts;
in {
  options.godtamnix.system.fonts = with types; {
    enable = lib.mkEnableOption "managing fonts";
    fonts = with pkgs;
      mkOpt (listOf package) [
        font-awesome

        # Desktop Fonts
        b612 # high legibility
        corefonts # MS fonts
        comic-neue
        material-icons
        material-design-icons
        mona-sans
        noto-fonts
        source-sans
        source-serif
        work-sans
        inter
        lexend

        # Emojis
        noto-fonts-color-emoji
        noto-fonts-monochrome-emoji

        # Nerd Fonts
        cascadia-code
        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
        nerd-fonts.symbols-only
      ] "Custom font packages to install.";
    default = mkOpt types.str "Source Sans 3" "Default font name";
    size = mkOpt types.int 11 "Default font size";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      # Enable icons in tooling since we have nerdfonts.
      LOG_ICONS = "true";
    };
  };
}
