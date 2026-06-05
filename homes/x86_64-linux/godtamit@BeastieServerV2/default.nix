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
        sqlEnable = false;
        aiEnable = true;
      };

      gaming = enabled;
      multimedia = enabled;

      video = {
        enable = true;
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
          wayle = {
            enable = true;
            settings = fromTOML (builtins.readFile ./wayle.toml);
          };
        };

        browsers = {
          brave = {
            enable = true;
            commandLineArgs = [
              # Intel VAAPI (iHD backend, set by hardware.gpu.intel module):
              #   https://github.com/chromium/chromium/blob/main/docs/gpu/vaapi.md#vaapi-on-linux
              "--enable-features=UseOzonePlatform,VaapiVideoDecodeLinuxGL,VaapiVideoEncoderLinuxGL"
              "--ozone-platform=wayland"

              # TODO(https://issues.chromium.org/issues/476172415): Remove once fixed
              "--disable-features=WaylandWpColorManagerV1"
            ];
          };

          google-chrome = enabled;
        };

        desktop = {
          wayland = enabled;
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

    fish = {
      shellInit = ''
        set -x PLEX /mnt/array-media/Plex/
        set -x CMP /mnt/array-media/docker/data/completed/
        set -x UP /mnt/array-media/docker/data/uploaded/
      '';
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
            # TODO(BeastieServerV2): adjust the monitor name to match your connected
            # display (run `niri msg outputs` to list them). Common: HDMI-A-1, DP-1,
            # eDP-1 for laptops, or whatever your TV reports over HDMI.
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
      thunar
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

  home.stateVersion = "25.11";
}
