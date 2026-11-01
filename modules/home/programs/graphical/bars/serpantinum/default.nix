{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
with lib; let
  cfg = config.godtamnix.programs.graphical.bars.serpantinum;
  isLinux = hasSuffix "linux" system;
  jsonFormat = pkgs.formats.json {};

  templateSettings = builtins.fromJSON (builtins.readFile "${inputs.serpantinum}/config/serpantinum/settings.json");
  userSettings = filterAttrsRecursive (_: v: v != null) config.programs.serpantinum.settings;
  settingsFile = jsonFormat.generate "serpantinum-settings.json" (recursiveUpdate templateSettings userSettings);

  initialize = pkgs.writeShellApplication {
    name = "serpantinum-declarative-state";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      config_dir="$HOME/.config/serpantinum"
      install -d "$config_dir"
      temporary=$(mktemp "$config_dir/.settings.XXXXXX")
      trap 'rm -f "$temporary"' EXIT
      install -m 0644 ${escapeShellArg settingsFile} "$temporary"
      mv -fT "$temporary" "$config_dir/settings.json"
      trap - EXIT
      ${optionalString (cfg.wallpapers != {}) ''
        cache_dir="$HOME/.cache/serpantinum/wallpaper"
        install -d "$cache_dir"
        write_selection() {
          temporary=$(mktemp "$cache_dir/.selection.XXXXXX")
          trap 'rm -f "$temporary"' EXIT
          printf '%s\n' "$2" > "$temporary"
          chmod 0644 "$temporary"
          mv -fT "$temporary" "$1"
          trap - EXIT
        }
        ${concatStringsSep "\n" (mapAttrsToList (output: image: ''
            write_selection "$cache_dir"/${escapeShellArg "current_${output}"} ${escapeShellArg (toString image)}
            write_selection "$cache_dir"/${escapeShellArg "current_${output}_name"} ${escapeShellArg (baseNameOf (toString image))}
            install -m 0644 -T ${escapeShellArg (toString image)} "$cache_dir"/${escapeShellArg "current_wallpaper_${output}.png"}
          '')
          cfg.wallpapers)}
        install -m 0644 -T ${escapeShellArg (toString (head (attrValues cfg.wallpapers)))} "$cache_dir/current_wallpaper.png"

        # Declared wallpapers replace the first-run wizard's random selection.
        install -d "$HOME/.local/state/serpantinum"
        touch "$HOME/.local/state/serpantinum/first_launch.done"
      ''}
    '';
  };
in {
  imports = optionals isLinux [
    inputs.serpantinum.homeManagerModules.default
  ];

  options.godtamnix.programs.graphical.bars.serpantinum = {
    enable = mkEnableOption "Serpantinum, a Quickshell-based Wayland shell/bar";

    autostart = mkOption {
      type = types.bool;
      default = true;
      description = "Start Serpantinum's systemd user service with the graphical session.";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Settings layered over upstream defaults and reapplied at Home Manager
        activation and service startup. The native GUI can edit the writable
        copy until the next activation or startup.
      '';
    };

    wallpapers = mkOption {
      type = types.attrsOf types.path;
      default = {};
      description = ''
        Wallpaper image paths keyed by output name. Selections are restored to
        Serpantinum's native writable cache at activation and service startup.
        The first output's image also supplies the shared lock/blur snapshot.
      '';
    };
  };

  config = mkIf cfg.enable (optionalAttrs isLinux {
    assertions = [
      {
        assertion = config.xdg.configHome == "${config.home.homeDirectory}/.config";
        message = "Serpantinum's native settings loader requires the default XDG_CONFIG_HOME.";
      }
      {
        assertion = all (output: output != "" && !(hasInfix "/" output)) (attrNames cfg.wallpapers);
        message = "Serpantinum wallpaper output names must be nonempty and cannot contain '/'.";
      }
    ];

    programs.serpantinum = {
      enable = true;
      systemd.enable = cfg.autostart;
      inherit (cfg) settings;
    };

    # Upstream only seeds settings once; reapply without a symlink its writer can replace.
    home.activation.serpantinumSettings = mkForce (
      lib.hm.dag.entryBetween ["reloadSystemd"] ["linkGeneration"] ''
        run ${getExe initialize}
      ''
    );

    systemd.user.services.serpantinum = mkIf config.programs.serpantinum.systemd.enable {
      Unit.X-Restart-Triggers = ["${initialize}"];
      Service.ExecStartPre = [(getExe initialize)];
    };
  });
}
