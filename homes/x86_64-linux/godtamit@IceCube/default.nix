{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  imports = [
    ../../users/godtamit
  ];

  godtamnix = {
    # This gets the basic nix options setup.
    nix = enabled;

    # Create the user account.
    user = {
      enable = true;
      name = "godtamit";
      fullName = "Christopher Tam";
      email = lib.godtamnix.decode "b2hnb2R0YW1pdEBnbWFpbC5jb20=";
    };

    suites = {
      development = {
        enable = true;
        awsEnable = true;
        digitaloceanEnable = true;
        dockerEnable = true;
        kubernetesEnable = true;
        nixEnable = true;
        sqlEnable = true;
      };

      multimedia = enabled;

      video = {
        enable = true;
        kdenliveEnable = true;
        obsEnable = true;
      };
    };

    theme = {
      catppuccin = enabled;
      stylix = enabled;
    };

    programs = {
      graphical = {
        bars = {
          waybar = {
            enable = true;

            modules = {
              workspaces = {
                enable = true;

                persistentWorkspaces = {
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

                formatIcons = {
                  "1" = "";
                  "2" = "󰈮";
                  "3" = "";
                  "4" = "󰭹";
                  "5" = "󰈹";
                  "6" = "󰎆";
                  "7" = "";
                  "8" = "󱤘";
                };
              };
            };
          };
        };

        browsers = {
          brave = {
            enable = true;
            commandLineArgs = [
              "--enable-features=UseOzonePlatform"
              "--ozone-platform=wayland"

              # TODO(https://issues.chromium.org/issues/476172415): Remove once fixed
              "--disable-features=WaylandWpColorManagerV1"
            ];
          };
        };

        desktop = {
          wayland = enabled;
          hyprland = enabled;
        };
      };
    };
  };

  home.packages = with pkgs; [
    foot
    kitty
    wofi
  ];

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
      #monitor = [
      #  "DP-5, 3840x2160@144, 0x0, 1.5, vrr, 1, bitdepth, 10, cm, hdr"
      #  "DP-6, 3840x2160@144, 3840x0, 1.5, vrr, 1, bitdepth, 10, cm, hdr"
      #];
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
        "1, monitor:DP-5, default:true"
        "2, monitor:DP-5"
        "3, monitor:DP-5"
        "4, monitor:DP-5"
        "5, monitor:DP-6"
        "6, monitor:DP-6"
        "7, monitor:DP-6"
        "8, monitor:DP-6"
      ];
    };
  };

  home.stateVersion = "25.11";
}
