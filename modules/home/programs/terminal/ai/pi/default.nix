{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.godtamnix.programs.terminal.ai.pi;
in {
  options.godtamnix.programs.terminal.ai.pi = {
    enable = lib.mkEnableOption "Pi terminal-based coding agent with multi-model support";

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Settings for pi, written to ~/.pi/agent/settings.json. Project
        settings (.pi/settings.json) override these at runtime. Pi packages
        (e.g. pi-tps-meter, pi-mcp-adapter) are declared in the `packages`
        array here and pi installs them automatically on startup.
      '';
    };

    mcp = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        MCP server configuration consumed by the pi-mcp-adapter package,
        written to ~/.pi/agent/mcp.json. Top-level keys are typically
        `mcpServers`, `settings`, and `imports`.
      '';
    };

    keybindings = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Keybindings for pi, written to ~/.pi/agent/keybindings.json. Keys are
        namespaced action ids (e.g. "tui.editor.cursorWordLeft"); each value is
        a single key string or an array of key strings. User config overrides
        defaults — set an action to `[]` to unbind it. Run /reload in pi after
        editing.
      '';
    };

    models = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Custom model definitions, written to ~/.pi/agent/models.json. Declares
        custom providers/models and per-model overrides for built-in providers;
        adding a `models` array to a built-in provider merges with its
        existing models rather than replacing them. See
        https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/models.md.
        Reloads every time /model is opened.
      '';
    };

    agentsDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a directory of pi-open-agents definition files, deployed to
        ~/.pi/agent/agents/. Each <name>.md becomes a loadable agent or
        subagent (pi-open-agents globs *.md at the top level). See
        https://github.com/andrea-tomassi/pi-open-agents
      '';
    };

    skillsDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a directory of pi skill definitions, deployed to
        ~/.pi/agent/skills/. pi auto-discovers top-level *.md files as
        individual skills and recurses into subdirectories that contain a
        SKILL.md. See
        https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md
      '';
    };
  };

  config = mkIf cfg.enable {
    home = {
      # pi shells out to `npm` to install the packages declared in
      # settings.json (into ~/.pi/agent/npm/). The nix-wrapped pi bundles its
      # own node runtime but doesn't expose npm on PATH, so child_process.spawn
      # fails with ENOENT — provide nodejs (which ships npm) for it to find.
      packages = with pkgs; [
        nodejs
        pi-coding-agent
      ];

      # pi reads its global config from ~/.pi/agent/ (NOT ~/.config/), so these
      # target the home directory directly — the same approach the opencode
      # module takes for ~/.agent-browser/config.json.
      file = {
        ".pi/agent/settings.json" = mkIf (cfg.settings != {}) {
          text = builtins.toJSON cfg.settings;
        };

        ".pi/agent/mcp.json" = mkIf (cfg.mcp != {}) {
          text = builtins.toJSON cfg.mcp;
        };

        ".pi/agent/keybindings.json" = mkIf (cfg.keybindings != {}) {
          text = builtins.toJSON cfg.keybindings;
        };

        ".pi/agent/models.json" = mkIf (cfg.models != {}) {
          text = builtins.toJSON cfg.models;
        };

        # pi-open-agents discovers agent/subagent definitions from
        # ~/.pi/agent/agents/*.md. Deploying the whole directory keeps the set
        # of agents declarative — drop a <name>.md into agentsDir to add one.
        ".pi/agent/agents".source = mkIf (cfg.agentsDir != null) cfg.agentsDir;

        # pi auto-discovers skills from ~/.pi/agent/skills/ (top-level *.md
        # files, plus subdirectories that contain a SKILL.md).
        ".pi/agent/skills".source = mkIf (cfg.skillsDir != null) cfg.skillsDir;
      };
    };
  };
}
