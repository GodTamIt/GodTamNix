{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.godtamnix.programs.terminal.ai.opencode;

  # Merge oh-my-openagent into the plugin list if it has configuration
  finalSettings =
    cfg.settings
    // lib.optionalAttrs (cfg.ohMyOpenAgent != {}) {
      plugin = lib.unique ((cfg.settings.plugin or []) ++ ["oh-my-openagent"]);
    };
in {
  options.godtamnix.programs.terminal.ai.opencode = {
    enable = lib.mkEnableOption "Open source AI coding agent";
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Settings for opencode (opencode.json)";
    };
    ohMyOpenAgent = mkOption {
      type = types.attrs;
      default = {};
      description = "Settings for oh-my-openagent (oh-my-openagent.jsonc)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optional (lib.elem "oh-my-openagent" (finalSettings.plugin or [])) pkgs.oh-my-opencode;

    programs.opencode = {
      enable = true;
      settings = finalSettings;
    };

    xdg.configFile."opencode/oh-my-openagent.jsonc" = mkIf (cfg.ohMyOpenAgent != {}) {
      text = builtins.toJSON cfg.ohMyOpenAgent;
    };
  };
}
