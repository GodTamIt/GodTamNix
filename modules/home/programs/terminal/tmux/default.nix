{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.programs.terminal.tmux;
in {
  options.godtamnix.programs.terminal.tmux = {
    enable = lib.mkEnableOption "tmux terminal multiplexer with extended key support";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      extraConfig = ''
        set -g extended-keys on
        set -g extended-keys-format csi-u
      '';
    };
  };
}
