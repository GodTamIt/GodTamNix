{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.programs.terminal.ai.rtk;
in {
  options.godtamnix.programs.terminal.ai.rtk = {
    enable = lib.mkEnableOption "High-performance CLI proxy that reduces LLM token consumption by 60-90%";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rtk
    ];
  };
}
