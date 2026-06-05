{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  imports = [
    ../../users/godtamit
    inputs.open-design.homeManagerModules.default
  ];

  godtamnix = {
    # This gets the basic nix options setup.
    nix = enabled;

    suites = {
      development = {
        enable = true;
        awsEnable = true;
        digitaloceanEnable = true;
        dockerEnable = true;
        kubernetesEnable = true;
        nixEnable = true;
        rustEnable = true;
        sqlEnable = true;
        aiEnable = true;
      };

      gaming = enabled;
      multimedia = enabled;

      video = {
        enable = true;
        kdenliveEnable = true;
        obsEnable = true;
      };
    };

    theme = {
      catppuccin = enabled;
      gtk = {
        enable = true;
        usePortal = true;
      };
      qt = enabled;
      stylix = enabled;
    };

    programs = {
      graphical = {
        bars = {
          noctalia = {
            enable = false;
            autostart = true;

            settings = {
              bar.default = {
                background_opacity = 0.5;
                center = ["active_window"];
                start = ["Vicinae" "wallpaper" "workspaces" "clock" "weather"];
                end = [
                  "media"
                  "notifications"
                  "clipboard"
                  "network"
                  "bluetooth"
                  "volume"
                  "cpu"
                  "ram"
                  "battery"
                  "control-center"
                  "session"
                ];
                margin_ends = 9;
                scale = 1.1;
                widget_spacing = 16;
              };

              lockscreen.blurred_desktop = true;

              shell = {
                font_family = "Noto Sans";
                settings_show_advanced = true;
                telemetry_enabled = true;
              };

              theme = {
                source = "community";
                community_palette = "Catppuccin Lavender";
                wallpaper_scheme = "m3-tonal-spot";
              };

              weather = {
                address = "Jersey City, NJ, United States";
                refresh_minutes = 10;
                unit = "imperial";
              };

              widget = {
                Vicinae = {
                  type = "custom_button";
                  command = "vicinae toggle";
                  glyph = "search";
                };
                media = {
                  art_size = 32.0;
                  max_length = 120;
                  title_scroll = "always";
                };
              };
            };
          };

          wayle = {
            enable = true;
            settings = fromTOML (builtins.readFile ./wayle.toml);
          };
        };

        browsers = {
          brave = {
            enable = true;
            commandLineArgs = [
              # Note:
              #   * https://github.com/chromium/chromium/blob/main/docs/gpu/vaapi.md#vaapi-on-linux
              #   * https://canonical.github.io/inbrowser-encode-test/
              "--enable-features=UseOzonePlatform,VaapiOnNvidiaGPUs,AcceleratedVideoEncoder"
              "--ozone-platform=wayland"

              # TODO(https://issues.chromium.org/issues/476172415): Remove once fixed
              "--disable-features=WaylandWpColorManagerV1"
            ];
          };

          google-chrome = enabled;
        };

        desktop = {
          wayland = enabled;
          # hyprland = enabled;
          niri = enabled;
        };

        launchers = {
          vicinae = enabled;
        };

        tools = {
          mangohud = {
            enable = true;
            enableSessionWide = true;
          };
        };
      };
    };
  };

  programs = {
    direnv = {
      config = {
        whitelist = {
          prefix = [
            "${config.home.homeDirectory}/src/assist"
          ];
        };
      };
    };

    wlogout = {
      enable = true;

      layout = [
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
        }
        # {
        #   label = "hibernate";
        #   action = "systemctl hibernate";
        #   text = "Hibernate";
        #   keybind = "h";
        # }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
    };
  };

  services = {
    # open-design = {
    #   enable = true;
    #   autoStart = true;

    #   webFrontend = {
    #     enable = true;
    #     host = "http://127.0.0.1";
    #     port = 17457;

    #     allowedOrigins = [
    #       "http://localhost:17457"
    #       "https://localhost:17457"
    #       "http://127.0.0.1:17457"
    #       "https://127.0.0.1:17457"
    #     ];
    #   };
    # };

    hyprpaper = {
      enable = true;

      settings = {
        wallpaper = [
          {
            monitor = "DP-5";
            path = "${pkgs.godtamnix.wallpapers}/share/wallpapers/cyberpunk-mclaren-0.png";
            fit_mode = "cover";
          }
          {
            monitor = "DP-6";
            path = "${pkgs.godtamnix.wallpapers}/share/wallpapers/cyberpunk-mclaren-1.png";
            fit_mode = "cover";
          }
          {
            monitor = "";
            path = "${pkgs.godtamnix.wallpapers}/share/wallpapers/cyberpunk-mclaren.png";
          }
        ];
      };
    };

    udiskie = {
      enable = true;
      automount = true;
    };
  };

  home = {
    packages = with pkgs; [
      onlyoffice-desktopeditors
      thunar
      zoom-us
    ];

    sessionVariables = {
      BROWSER = "firefox";
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common.default = "*";
    };

    mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";
      };
    };

    # niri host-specific config (outputs, workspace pinning, mouse, autostart).
    # The generic config.kdl in the shared user config pulls this in via
    # `include "host.kdl"`. Gated so it only deploys when niri is enabled here.
    configFile = lib.optionalAttrs config.godtamnix.programs.graphical.desktop.niri.enable {
      "niri/host.kdl".source = ./niri-host.kdl;
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      device = [
        {
          name = "keyboard";
          kb_layout = "us";
        }
        {
          name = "mouse";
          sensitivity = -0.5;
        }
      ];
      exec-once = [
        "[workspace 4 silent] ferdium"
        "[workspace 4 silent] signal-desktop"
        "[workspace 6 silent] ytmdesktop"
        "[workspace 5 silent] firefox"
        "[workspace 2 silent] antigravity"
      ];
      monitorv2 = [
        {
          #output = "desc:207NTQDFW364";
          output = "DP-5";
          mode = "3840x2160@144";
          position = "0x0";
          scale = 1.33;
          bitdepth = 10;
          cm = "hdr";
          supports_hdr = 1;
          supports_wide_color = true;
          sdr_max_luminance = 250;
          max_luminance = 600;
          vrr = 1;
        }
        {
          #output = "desc:207NTZNFW341";
          output = "DP-6";
          mode = "3840x2160@144";
          position = "auto";
          scale = 1.33;
          bitdepth = 10;
          cm = "hdr";
          supports_hdr = 1;
          supports_wide_color = true;
          sdr_max_luminance = 250;
          max_luminance = 600;
          vrr = 1;
        }
      ];

      workspace = [
        "1, monitor:DP-5, persistent:true, default:true"
        "2, monitor:DP-5, persistent:true"
        "3, monitor:DP-5, persistent:true"
        "4, monitor:DP-5, persistent:true"
        "5, monitor:DP-6, persistent:true"
        "6, monitor:DP-6, persistent:true"
        "7, monitor:DP-6, persistent:true"
        "8, monitor:DP-6, persistent:true"
      ];
    };
  };

  home.stateVersion = "25.11";
}
