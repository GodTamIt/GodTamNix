{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    types
    mkIf
    mkDefault
    mkMerge
    ;
  inherit (lib.godtamnix) mkOpt enabled;

  cfg = config.godtamnix.user;

  home-directory =
    if cfg.name == null
    then null
    else if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${cfg.name}"
    else "/home/${cfg.name}";
in {
  options.godtamnix.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    email = mkOpt (types.nullOr types.str) null "The email of the user.";
    fullName = mkOpt (types.nullOr types.str) null "The full name of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    icon = mkOpt (types.nullOr types.package) null "The profile picture to use for the user.";
    name = mkOpt (types.nullOr types.str) null "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "godtamnix.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "godtamnix.user.home must be set";
        }
      ];

      home = {
        file =
          {
            "Desktop/.keep".text = "";
            "Documents/.keep".text = "";
            "Downloads/.keep".text = "";
            "Music/.keep".text = "";
            "Pictures/.keep".text = "";
            "Videos/.keep".text = "";
          }
          // lib.optionalAttrs (cfg.icon != null) {
            ".face".source = cfg.icon;
            ".face.icon".source = cfg.icon;
            "Pictures/${cfg.icon.fileName or (baseNameOf cfg.icon)}".source = cfg.icon;
          };

        # Only set homeDirectory if cfg.home is not null
        homeDirectory = mkIf (cfg.home != null) (mkDefault cfg.home);

        username = mkDefault cfg.name;
      };

      programs = {
        home-manager = enabled;

        git = mkMerge [
          {enable = true;}
          (mkIf (cfg.fullName != null) {
            settings.user.name = cfg.fullName;
          })
          (mkIf (cfg.email != null) {
            settings.user.email = cfg.email;
          })
        ];
      };
    }
  ]);
}
