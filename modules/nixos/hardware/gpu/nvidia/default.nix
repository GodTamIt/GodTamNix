{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.godtamnix.hardware.gpu.nvidia;
in {
  options.godtamnix.hardware.gpu.nvidia = {
    enable = mkEnableOption "Nvidia GPU configuration";

    open = mkOption {
      type = types.bool;
      default = true;
      description = "Use the Nvidia open source kernel module";
    };

    powerManagement = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Nvidia power management. Experimental, and can cause sleep/suspend to fail.";
      };

      finegrained = mkOption {
        type = types.bool;
        default = false;
        description = "Enable fine-grained power management. Turns off GPU when not in use. Experimental and only works on modern Nvidia GPUs (Turing or newer).";
      };
    };

    powerLimit = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Power limit in Watts to apply to the Nvidia GPU";
    };
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    boot.blacklistedKernelModules = ["nouveau"];

    hardware = {
      graphics = {
        enable = true;

        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          ocl-icd
        ];
      };

      nvidia = {
        # Modesetting is required
        modesetting.enable = true;

        powerManagement = {
          inherit (cfg.powerManagement) enable finegrained;
        };

        # Use the Nvidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures.
        inherit (cfg) open;

        # Enable the Nvidia settings menu.
        nvidiaSettings = true;

        # Enable the nvidia-persistenced service
        nvidiaPersistenced = true;

        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };

    environment = {
      sessionVariables = {
        # Apps can use the NVIDIA VA-API bridge
        LIBVA_DRIVER_NAME = "nvidia";
        # Required for the VA-API driver to work on Wayland
        NVD_BACKEND = "direct";
        # OpenGL apps use the NVIDIA driver
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";

        GBM_BACKEND = "nvidia-drm";
      };

      systemPackages = with pkgs; [
        libva-utils
        nvtopPackages.nvidia
      ];
    };

    # Systemd service for power limit
    systemd.services.nvidia-power-limit = mkIf (cfg.powerLimit != null) {
      description = "Set Nvidia GPU Power Limit";
      wantedBy = ["multi-user.target"];
      # Ensure drivers are loaded
      after = [
        "nvidia-persistenced.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        # We need to run as root
        User = "root";
        # Path to nvidia-smi might depend on the driver package
        # Using config.hardware.nvidia.package/bin/nvidia-smi
        ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pl ${toString cfg.powerLimit}";
      };
    };
  };
}
