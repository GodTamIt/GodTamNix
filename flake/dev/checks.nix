{
  inputs,
  lib,
  ...
}: {
  imports = lib.optional (inputs.git-hooks-nix ? flakeModule) inputs.git-hooks-nix.flakeModule;

  perSystem = {pkgs, ...}: {
    pre-commit = lib.mkIf (inputs.git-hooks-nix ? flakeModule) {
      check.enable = false;

      settings.hooks = {
        # FIXME: broken dependency on darwin
        actionlint.enable = pkgs.stdenv.hostPlatform.isLinux;
        clang-tidy.enable = true;
        deadnix = {
          enable = true;

          settings = {
            edit = true;
          };
        };
        eslint = {
          enable = true;
          package = pkgs.eslint_d;
        };
        luacheck.enable = true;
        pre-commit-hook-ensure-sops = {
          enable = true;
          # The hook json/yaml-parses every file under secrets/ to verify it's
          # encrypted. Docs like secrets/*/README.md aren't secrets and aren't
          # parseable, so exclude Markdown.
          excludes = ["\\.md$"];
        };
        statix.enable = true;
        treefmt.enable = true;
        typos = {
          enable = true;
          excludes = ["generated/*"];
        };
      };
    };

    checks = {
      # TODO:
      # Custom checks can go here
      # nix-syntax = pkgs.runCommand "check-nix-syntax" { } ''
      #   find ${./../..} -name "*.nix" -exec ${pkgs.nix}/bin/nix-instantiate --parse {} \; > /dev/null
      #   touch $out
      # '';
    };
  };
}
