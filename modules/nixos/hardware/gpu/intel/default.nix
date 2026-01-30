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
  cfg = config.godtamnix.hardware.gpu.intel;
in {
  options.godtamnix.hardware.gpu.intel = {
    enable = mkEnableOption "Intel GPU configuration";

    enableCompute = mkOption {
      type = types.bool;
      default = true;
      description = "Enable compute capabilities for the Intel GPU";
    };
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["modesetting"];

    boot.kernelParams = ["i915.enable_guc=3"];

    hardware = {
      graphics = {
        enable = true;

        extraPackages = with pkgs;
          [
            intel-media-driver # VA-API (iHD) userspace
            vpl-gpu-rt # oneVPL (QSV) runtime
          ]
          ++ lib.optionals cfg.enableCompute [
            intel-compute-runtime # OpenCL (NEO) + Level Zero for Arc/Xe
          ];
      };

      enableRedistributableFirmware = true;
    };

    environment = {
      sessionVariables = {
        # Prefer the modern iHD backend
        LIBVA_DRIVER_NAME = "iHD";
      };
    };
  };
}
