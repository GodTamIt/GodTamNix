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

    # Distinct shell packages across all managed users, so we can register
    # them in /etc/shells (required for `chsh` and macOS to honor them).
    userShells = lib.unique (lib.mapAttrsToList (_: u: u.shell) cfg);
    usesFish = builtins.any (s: s == pkgs.fish) userShells;
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

    # Register managed shells in /etc/shells so macOS accepts them as login
    # shells (chsh refuses anything not listed there).
    environment.shells = userShells;

    # System-level fish enables vendor completions and other integration that
    # home-manager's per-user `programs.fish` doesn't cover.
    programs.fish.enable = usesFish;

    # nix-darwin only updates the macOS Open Directory `UserShell` for users it
    # creates itself (those listed in `users.knownUsers` with a `uid`). For
    # pre-existing macOS users — the common case — the login shell stays at
    # whatever macOS set it to, regardless of `users.users.<name>.shell`.
    # Force-sync it via `dscl` on every activation so terminals (kitty, Terminal,
    # iTerm2, Ghostty) pick up the configured shell.
    #
    # Must hook `postActivation` (one of the three customizable entry points,
    # alongside `preActivation` and `extraActivation`) — arbitrarily-named keys
    # under `system.activationScripts` are accepted by the option type but
    # never invoked by `/run/current-system/activate`.
    system.activationScripts.postActivation.text = let
      entries = lib.mapAttrsToList (name: userCfg: ''
        target="${userCfg.shell}/bin/${userCfg.shell.meta.mainProgram or (lib.getName userCfg.shell)}"
        current=$(/usr/bin/dscl . -read /Users/${name} UserShell 2>/dev/null | /usr/bin/awk '{print $2}' || true)
        if [ -n "$target" ] && [ "$current" != "$target" ]; then
          echo "setting login shell for ${name} to $target (was $current)"
          /usr/bin/dscl . -create /Users/${name} UserShell "$target"
        fi
      '') cfg;
    in
      lib.concatStringsSep "\n" entries;
  };
}
