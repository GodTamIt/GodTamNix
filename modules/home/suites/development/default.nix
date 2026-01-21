{
  config,
  lib,
  pkgs,
  # osConfig ? { },
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.godtamnix) enabled;

  cfg = config.godtamnix.suites.development;
  # isWSL = osConfig.godtamnix.archetypes.wsl.enable or false;
  isWSL = false;
in {
  options.godtamnix.suites.development = {
    enable = lib.mkEnableOption "common development configuration";
    awsEnable = lib.mkEnableOption "AWS development configuration";
    digitaloceanEnable = lib.mkEnableOption "DigitalOcean development configuration";
    dockerEnable = lib.mkEnableOption "docker development configuration";
    gameEnable = lib.mkEnableOption "game development configuration";
    goEnable = lib.mkEnableOption "go development configuration";
    kubernetesEnable = lib.mkEnableOption "Kubernetes development configuration";
    nixEnable = lib.mkEnableOption "nix development configuration";
    sqlEnable = lib.mkEnableOption "sql development configuration";
    aiEnable = lib.mkEnableOption "ai development configuration";
  };

  config = mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;

        nix-direnv = enabled;

        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;

        silent = true;
      };

      kitty = {
        enable = true;
        enableGitIntegration = true;

        font = {
          name = "MonaspaceNeon NF";
          size = 9;
        };

        shellIntegration = {
          enableFishIntegration = true;
        };
      };
    };

    home.packages = with pkgs;
      [
        antigravity
        go
        jq
        rclone
        rsync
      ]
      ++ lib.optionals (!isWSL) [
        # bruno
        # neovide
        postman
      ]
      ++ lib.optionals cfg.awsEnable [
        awscli
      ]
      ++ lib.optionals cfg.dockerEnable [
        podman
        podman-tui
      ]
      ++ lib.optionals cfg.digitaloceanEnable [
        doctl
      ]
      ++ lib.optionals cfg.nixEnable [
        hydra-check
        # godtamnix.build-by-path
        alejandra
        nix-bisect
        nix-diff
        nix-fast-build
        nix-health
        nix-output-monitor
        nix-update
        nixpkgs-hammering
        nixpkgs-lint-community
        nixpkgs-review
        nurl
      ]
      ++ lib.optionals cfg.gameEnable (
        [gdevelop]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          godot
          # NOTE: removed from nixpkgs
          # Unreal Engine 4
          unityhub
        ]
      )
      ++ lib.optionals cfg.kubernetesEnable [
        atmos
        kubectl
        kubectx
        kubernetes-helmPlugins.helm-diff
        helm
        helmfile
      ]
      ++ lib.optionals cfg.sqlEnable [
        dbeaver-bin
        beekeeper-studio
      ]
      ++ lib.optionals cfg.aiEnable [
        # NOTE: hard to get out of neovim
        # antigravity
        github-mcp-server
        github-copilot-cli
      ];
  };
}
