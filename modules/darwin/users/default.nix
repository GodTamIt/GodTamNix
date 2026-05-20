{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption mkIf;

  cfg = config.godtamnix.users;
in {
  options.godtamnix.users = mkOption {
    description = "Attribute set of Darwin users to manage.";
    default = {};
    type = types.attrsOf (
      types.submodule {
        options = {
          fullName = mkOption {
            type = types.str;
            default = "Christopher Tam";
          };
          isTrusted = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to add this user to nix.settings.trusted-users.";
          };
          isPrimary = mkOption {
            type = types.bool;
            default = false;
            description = "Mark this user as the primary user for nix-darwin (system-wide defaults).";
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

  config = let
    primaryUsers = lib.filterAttrs (_: u: u.isPrimary) cfg;
    primaryUserName =
      if primaryUsers == {}
      then null
      else builtins.head (builtins.attrNames primaryUsers);
  in {
    users.users =
      lib.mapAttrs (
        name: userCfg: {
          description = userCfg.fullName;
          home = "/Users/${name}";
          inherit (userCfg) shell;
        }
      )
      cfg;

    nix.settings.trusted-users = let
      trustedUserNames = lib.mapAttrsToList (name: _: name) (
        lib.filterAttrs (_: u: u.isTrusted) cfg
      );
    in
      ["root" "@admin"] ++ trustedUserNames;

    # nix-darwin needs to know the "owner" of user-scoped defaults
    system.primaryUser = mkIf (primaryUserName != null) primaryUserName;
  };
}
