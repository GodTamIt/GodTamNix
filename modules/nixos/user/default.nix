{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types mkOption;
  cfg = config.godtamnix.users;
in
{
  options.godtamnix.users = mkOption {
    description = "Attribute set of users to create.";
    default = { };
    type = types.attrsOf (
      types.submodule {
        options = {
          fullName = mkOption {
            type = types.str;
            default = "Christopher Tam";
          };
          initialPassword = mkOption {
            type = types.str;
            default = "password";
          };
          isTrusted = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to add this user to nix.settings.trusted-users.";
          };
          extraGroups = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          extraOptions = mkOption {
            type = types.attrs;
            default = { };
          };
          shell = mkOption {
            type = types.package;
            default = pkgs.fish;
            description = "The shell to use for the user.";
          };
        };
      }
    );
  };

  config = {
    users.users = lib.mapAttrs (
      name: userCfg:
      {
        inherit (userCfg) initialPassword;
        description = userCfg.fullName;
        isNormalUser = true;
        group = "users";
        home = "/home/${name}";
        inherit (userCfg) shell;

        extraGroups = [
          "wheel"
          "audio"
          "video"
          "input"
        ]
        ++ userCfg.extraGroups;

      }
      // userCfg.extraOptions
    ) cfg;

    # Add specific users to the trusted-users list
    nix.settings.trusted-users =
      let
        # Filter the users where isTrusted is set to true, then extract their names
        trustedUserNames = lib.mapAttrsToList (name: userCfg: name) (
          lib.filterAttrs (name: userCfg: userCfg.isTrusted) cfg
        );
      in
      # Prepend "root" as it's usually good practice to keep it there
      [ "root" ] ++ trustedUserNames;
  };
}
