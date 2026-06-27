{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.godtamnix.programs.terminal.ai.opencode;

  ab = cfg.agentBrowser;

  # Merge plugins into the plugin list if they have configuration
  extraPlugins =
    (lib.optional (cfg.ohMyOpenAgent != {}) "oh-my-openagent")
    ++ (lib.optional (cfg.ohMyOpenCodeSlim != {}) "oh-my-opencode-slim");

  # agent-browser reads this on every CLI/daemon invocation, so the browser
  # binary it drives is pinned at build time and survives shell reloads.
  agentBrowserConfig = builtins.toJSON {
    "$schema" = "https://agent-browser.dev/schema.json";
    executablePath = ab.executable;
    inherit (ab) headed;
    args = lib.concatStringsSep "," ab.args;
  };

  finalSettings =
    cfg.settings
    // {
      plugin = lib.unique ((cfg.settings.plugin or []) ++ extraPlugins);
    }
    // lib.optionalAttrs ab.enable {
      # Let the agent invoke the CLI without prompting each time. Deep-merged
      # so any existing bash permission rules are preserved.
      permission = lib.recursiveUpdate (cfg.settings.permission or {}) {
        bash."agent-browser *" = "allow";
      };
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
    agentBrowser = mkOption {
      type = types.submodule {
        options = {
          enable = lib.mkEnableOption "the agent-browser CLI and browser-automation backend. Installs the `agent-browser` nixpkgs package, writes `~/.agent-browser/config.json` pointing it at a real browser, and allows `agent-browser *` bash commands.";

          executable = mkOption {
            type = types.str;
            default = "${pkgs.brave}/bin/brave";
            defaultText = lib.literalExpression "\${pkgs.brave}/bin/brave";
            description = ''
              Absolute path to the browser binary agent-browser should drive
              (instead of downloading its own Chromium). Defaults to the
              nixpkgs Brave wrapper. Override with e.g.
              `''${pkgs.google-chrome}/bin/google-chrome-stable` for Chrome.
            '';
          };

          headed = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to show the browser window during automation.";
          };

          args = mkOption {
            type = types.listOf types.str;
            default = ["--disable-dev-shm-usage"];
            defaultText = lib.literalExpression ''["--disable-dev-shm-usage"]'';
            description = ''
              Extra Chromium launch args forwarded to the browser. Joined with
              commas in the agent-browser config. Add `--no-sandbox` here if the
              browser fails to launch with a sandbox error, and `--ozone-
              platform=wayland` if using a raw (unwrapped) binary on Wayland.
            '';
          };
        };
      };
      default = {};
      description = "agent-browser browser-automation setup.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.flatten [
      (lib.optional (lib.elem "oh-my-openagent" (finalSettings.plugin or [])) pkgs.oh-my-opencode)
      # The CLI the agent-browser skill invokes via Bash. On NixOS we point it
      # at an existing browser (see ~/.agent-browser/config.json) rather than
      # running `agent-browser install`, which would download a Chromium that
      # lacks NixOS system deps.
      (lib.optional ab.enable pkgs.agent-browser)
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

    # agent-browser reads ~/.agent-browser/config.json (NOT ~/.config/) on every
    # CLI/daemon launch. home.file (not xdg.configFile) targets the home dir.
    home.file.".agent-browser/config.json" = mkIf ab.enable {
      text = agentBrowserConfig;
    };
  };
}
