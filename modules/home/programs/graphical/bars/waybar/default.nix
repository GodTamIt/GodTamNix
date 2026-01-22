{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.godtamnix.programs.graphical.bars.waybar;

  # Helper to make modules conditional
  mkModule = condition: name:
    if condition
    then [name]
    else [];
in {
  options.godtamnix.programs.graphical.bars.waybar = {
    enable = mkEnableOption "Waybar";

    style = mkOption {
      type = types.lines;
      default = builtins.readFile ./style.css;
      description = "The CSS style to use for Waybar.";
    };

    modules = {
      launcher = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };
            onClick = mkOption {
              type = types.str;
              default = "${pkgs.vicinae}/bin/vicinae toggle";
              description = "Action on click.";
            };
          };
        };
      };
      tray = mkOption {
        type = types.bool;
        default = true;
      };
      clock = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };
            format = mkOption {
              type = types.str;
              default = " {:%T}";
              description = "Format for the clock module.";
            };
            tooltipFormat = mkOption {
              type = types.str;
              default = "{:%A, %b %d, %Y}";
              description = "Tooltip format for the clock module.";
            };
          };
        };
      };
      network = mkOption {
        type = types.bool;
        default = true;
      };
      battery = mkOption {
        type = types.bool;
        default = true;
      };
      bluetooth = mkOption {
        type = types.bool;
        default = true;
      };
      pipewire = mkOption {
        type = types.bool;
        default = true;
        description = "Enables wireplumber module";
      };
      backlight = mkOption {
        type = types.bool;
        default = true;
      };
      temperature = mkOption {
        type = types.bool;
        default = true;
      };
      memory = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };
            format = mkOption {
              type = types.str;
              default = " {used:0.1f}G/{total:0.1f}G";
              description = "Format for the memory module.";
            };
            interval = mkOption {
              type = types.int;
              default = 10;
              description = "Update interval for the memory module.";
            };
            tooltip = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to show a tooltip for the memory module.";
            };
            tooltipFormat = mkOption {
              type = types.str;
              default = "RAM: {used:0.2f}G/{total:0.2f}G";
              description = "Tooltip format for the memory module.";
            };
            onClick = mkOption {
              type = types.str;
              default = "missioncenter";
              description = "Action on click.";
            };
          };
        };
      };
      cpu = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };
            format = mkOption {
              type = types.str;
              default = " {usage}%";
              description = "Format for the cpu module.";
            };
            interval = mkOption {
              type = types.int;
              default = 2;
              description = "Update interval for the cpu module.";
            };
            tooltip = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to show a tooltip for the cpu module.";
            };
            onClick = mkOption {
              type = types.str;
              default = "missioncenter";
              description = "Action on click.";
            };
          };
        };
      };
      power = mkOption {
        type = types.bool;
        default = true;
        description = "Enables lock, suspend, reboot, and power buttons";
      };
      weather = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };
            temperatureUnit = mkOption {
              type = types.enum [
                "C"
                "F"
              ];
              default = "F";
              description = "Temperature unit to use (C or F).";
            };
          };
        };
      };
      workspaces = mkOption {
        default = {};
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to enable Hyprland workspaces module.";
            };
            allOutputs = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to show all workspaces on all outputs.";
            };
            format = mkOption {
              type = types.str;
              default = "{icon}";
              description = "Format for the workspace module.";
            };
            onClick = mkOption {
              type = types.str;
              default = "activate";
              description = "Action on click.";
            };
            persistentWorkspaces = mkOption {
              type = types.attrs;
              default = {
                "*" = [
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                  8
                ];
              };
              description = "Persistent workspaces configuration.";
            };
            formatIcons = mkOption {
              type = types.attrs;
              default = {
                "1" = "";
                "2" = "󰈮";
                "3" = "";
                "4" = "󰭹";
                "5" = "󰈹";
                "6" = "󰎆";
                "7" = "";
                "8" = "󱤘";
              };
              description = "Icons for workspaces.";
            };
            disableScroll = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to disable scrolling on workspaces.";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      inherit (cfg) style;
      settings = {
        mainbar = {
          layer = "top";
          position = "top";
          height = 45;
          spacing = 0;

          modules-left =
            (mkModule cfg.modules.launcher.enable "custom/launcher")
            ++ (mkModule cfg.modules.workspaces.enable "hyprland/workspaces")
            ++ (mkModule cfg.modules.tray "tray")
            ++ (mkModule cfg.modules.power "custom/lock")
            ++ (mkModule cfg.modules.power "custom/suspend")
            ++ (mkModule cfg.modules.power "custom/reboot")
            ++ (mkModule cfg.modules.power "custom/power")
            ++ (mkModule cfg.modules.clock.enable "clock")
            ++ (mkModule cfg.modules.weather.enable "custom/weather");

          modules-center = ["hyprland/window"];

          modules-right =
            (mkModule cfg.modules.network "network")
            ++ (mkModule cfg.modules.battery "battery")
            ++ (mkModule cfg.modules.bluetooth "bluetooth")
            ++ (mkModule cfg.modules.pipewire "wireplumber")
            ++ (mkModule cfg.modules.backlight "backlight")
            ++ (mkModule cfg.modules.temperature "custom/temperature")
            ++ (mkModule cfg.modules.cpu.enable "cpu")
            ++ (mkModule cfg.modules.memory.enable "memory");

          "hyprland/workspaces" = {
            inherit (cfg.modules.workspaces) format;
            persistent-workspaces = cfg.modules.workspaces.persistentWorkspaces;
            format-icons = cfg.modules.workspaces.formatIcons;
            on-click = cfg.modules.workspaces.onClick;
            all-outputs = cfg.modules.workspaces.allOutputs;
            disable-scroll = cfg.modules.workspaces.disableScroll;
          };

          "custom/launcher" = {
            format = "";
            on-click = cfg.modules.launcher.onClick;
            tooltip = false;
          };

          "custom/lock" = {
            format = "";
            on-click = "${pkgs.hyprlock}/bin/hyprlock";
            tooltip = true;
            tooltip-format = "Lock Screen";
          };

          "custom/suspend" = {
            format = "󰤄";
            on-click = "systemctl suspend";
            tooltip = true;
            tooltip-format = "Suspend";
          };

          "custom/reboot" = {
            format = "";
            on-click = "systemctl reboot";
            tooltip = true;
            tooltip-format = "Reboot";
          };

          "custom/power" = {
            format = "";
            on-click = "systemctl poweroff";
            tooltip = true;
            tooltip-format = "Power Off";
          };

          network = {
            format-wifi = "󰤨 {essid}";
            format-ethernet = " Wired ";
            tooltip-format = "<span color='#FF1493'> 󰅧 </span>{bandwidthUpBytes}  <span color='#00BFFF'> 󰅢 </span>{bandwidthDownBytes}";
            #format-linked = "󱘖 {ifname} (No IP)";
            format-disconnected = " Disconnected";
            format-alt = "󰤨 {signalStrength}%";
            interval = 1;
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󱐋{capacity}%";
            interval = 1;
            format-icons = [
              "󰂎"
              "󰁼"
              "󰁿"
              "󰂁"
              "󰁹"
            ];
            tooltip = true;
          };

          wireplumber = {
            format = "{icon}{volume}%";
            format-muted = "󰖁 0%";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = " ";
              car = "  ";
              default = [
                "  "
                "  "
                "  "
              ];
            };
            on-click-right = "kitty --class 'floating_terminal' -e wiremix --tab output";
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            tooltip = true;
            tooltip-format = "Volume: {volume}%";
          };

          "custom/temperature" = {
            exec = "sensors | awk '/^Package id 0:/ {print int($4)}'";
            format = "{}°C";
            interval = 5;
            tooltip = true;
            tooltip-format = "CPU Temp: {}°C";
          };

          memory = {
            inherit (cfg.modules.memory) format;
            inherit (cfg.modules.memory) interval;
            inherit (cfg.modules.memory) tooltip;
            tooltip-format = cfg.modules.memory.tooltipFormat;
            on-click = cfg.modules.memory.onClick;
          };

          cpu = {
            inherit (cfg.modules.cpu) format;
            inherit (cfg.modules.cpu) interval;
            inherit (cfg.modules.cpu) tooltip;
            on-click = cfg.modules.cpu.onClick;
          };

          clock = {
            interval = 1;
            inherit (cfg.modules.clock) format;
            tooltip = true;
            tooltip-format = cfg.modules.clock.tooltipFormat;
          };

          tray = {
            icon-size = 17;
            spacing = 6;
          };

          backlight = {
            device = "intel_backlight";
            format = "{icon}{percent}%";
            tooltip = true;
            tooltip-format = "Brightness: {percent}%";
            format-icons = [
              "󰃞"
              "󰃝"
              "󰃟"
              "󰃠"
            ];
          };

          bluetooth = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias}{device_battery_percentage}%";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          };

          "custom/weather" = {
            format = "{}°${cfg.modules.weather.temperatureUnit}";
            tooltip = true;
            interval = 3600;
            exec = "wttrbar --location NYC --main-indicator temp_${cfg.modules.weather.temperatureUnit}";
            return-type = "json";
          };

          "hyprland/window" = {
            format = "{}";
            icon = true;
            separate-outputs = true;
          };
        };
      };
    };

    home.packages = with pkgs;
      [
        grim
        hyprlock
        qt6.qtwayland
        slurp
        waypipe
        wf-recorder
        wl-mirror
        wl-clipboard
        wlogout
        wtype
        ydotool
      ]
      ++ optional cfg.modules.temperature lm_sensors
      ++ optional cfg.modules.weather.enable wttrbar
      ++ optional cfg.modules.pipewire wiremix;
  };
}
