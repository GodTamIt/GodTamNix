{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.programs.terminal.ai.opencode;
in {
  options.godtamnix.programs.terminal.ai.opencode = {
    enable = lib.mkEnableOption "Open source AI coding agent";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
    };
  };
}
