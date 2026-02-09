{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.godtamnix.virtualisation.podman;
in {
  options.godtamnix.virtualisation.podman = {
    enable = lib.mkEnableOption "podman";

    emulatedSystems = mkOption {
      type = types.listOf types.str;
      default = ["aarch64-linux"];
      description = "List of systems to emulate via binfmt (e.g. for cross-architecture container builds).";
    };
  };

  config = mkIf cfg.enable {
    boot.binfmt = {
      inherit (cfg) emulatedSystems;
      preferStaticEmulators = true;
    };

    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    virtualisation = {
      podman = {
        inherit (cfg) enable;

        # prune images and containers periodically
        autoPrune = {
          enable = true;
          flags = ["--all"];
          dates = "weekly";
        };

        defaultNetwork.settings.dns_enabled = true;
        dockerCompat = true;
        dockerSocket.enable = true;
      };
    };
  };
}
