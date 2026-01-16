{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkIf;

  cfg = config.godtamnix.nix;
in
{
  imports = [ (lib.getFile "modules/common/nix/default.nix") ];

  options.godtamnix.nix = {
    enable = lib.mkEnableOption "Nix settings";
  };

  config = mkIf cfg.enable {
    documentation = {
      man.generateCaches = mkDefault true;

      nixos = {
        enable = true;

        options = {
          warningsAreErrors = true;
          splitBuild = true;
        };
      };
    };

    # NixOS config options
    # Check corresponding shared imported module
    nix = {
      # make builds run with low priority so my system stays responsive
      daemonCPUSchedPolicy = "batch";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;

      gc = {
        dates = "03:00";
        options = "--delete-older-than 30d";
      };

      optimise = {
        automatic = true;
        dates = [ "04:00" ];
      };

      settings = {
        auto-allocate-uids = true;
        # bail early on missing cache hits
        connect-timeout = 5;
        experimental-features = [ "nix-command flakes cgroups auto-allocate-uids" ];
        keep-going = true;
        use-cgroups = true;

        substituters = [
          "https://anyrun.cachix.org"
          "https://hyprland.cachix.org"
          "https://nix-gaming.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
          "https://attic.xuyh0120.win/lantian"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };
  };
}
