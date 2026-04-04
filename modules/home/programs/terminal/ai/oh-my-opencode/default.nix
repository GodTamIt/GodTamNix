{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.programs.terminal.ai.oh-my-opencode;
in {
  options.godtamnix.programs.terminal.ai.oh-my-opencode = {
    enable = lib.mkEnableOption "Open source AI coding agent (oh-my-opencode)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      oh-my-opencode
    ];
  };
}
