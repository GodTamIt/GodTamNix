{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.godtamnix.programs.terminal.ai.agent-browser;
in {
  options.godtamnix.programs.terminal.ai.agent-browser = {
    enable = lib.mkEnableOption "agent-browser browser automation";

    headed = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to show the browser window during automation.";
    };

    args = mkOption {
      type = types.listOf types.str;
      default = ["--disable-dev-shm-usage"];
      description = "Extra browser launch arguments.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.agent-browser];

    home.sessionVariables =
      {
        AGENT_BROWSER_HEADED =
          if cfg.headed
          then "1"
          else "0";
      }
      // lib.optionalAttrs (cfg.args != []) {
        # agent-browser 0.34.0 treats an empty args environment variable as a
        # launch override. Newlines preserve commas within individual Chromium args.
        AGENT_BROWSER_ARGS = lib.concatStringsSep "\n" cfg.args;
      };
  };
}
