{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.godtamnix.programs.terminal.ai.opencode;

  # Merge plugins into the plugin list if they have configuration
  extraPlugins =
    (lib.optional (cfg.ohMyOpenAgent != {}) "oh-my-openagent")
    ++ (lib.optional (cfg.ohMyOpenCodeSlim != {}) "oh-my-opencode-slim@2.0.0-beta.15");

  finalSettings =
    cfg.settings
    // {
      plugin = lib.unique ((cfg.settings.plugin or []) ++ extraPlugins);
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
    ohMyOpenCodeSlim = mkOption {
      type = types.attrs;
      default = {};
      description = "Settings for oh-my-opencode-slim (oh-my-opencode-slim.jsonc)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.flatten [
      (lib.optional (lib.elem "oh-my-openagent" (finalSettings.plugin or [])) pkgs.oh-my-opencode)
    ];

    programs.opencode = {
      enable = true;
      settings = finalSettings;
    };

    xdg.configFile."opencode/oh-my-openagent.jsonc" = mkIf (cfg.ohMyOpenAgent != {}) {
      text = builtins.toJSON cfg.ohMyOpenAgent;
    };

    xdg.configFile."opencode/oh-my-opencode-slim.jsonc" = mkIf (cfg.ohMyOpenCodeSlim != {}) {
      text = builtins.toJSON cfg.ohMyOpenCodeSlim;
    };
  };
}
