{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.godtamnix.programs.graphical.launchers.vicinae;
in {
  options.godtamnix.programs.graphical.launchers.vicinae = {
    enable = lib.mkEnableOption "vicinae in the desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.vicinae = {
      enable = true;
      package = pkgs.vicinae;

      # NOTE: Kinda annoying to have to manually fetch these revs.
      # Might be nice to automate this
      extensions =
        [
          # (config.lib.vicinae.mkRayCastExtension {
          #   name = "1password";
          #   rev = "1d1357202ec181978a698871b311f93d656122f6";
          #   sha256 = "sha256-JZdM4l3m3JQWoGqJOPoaywpSnlWA7pcEJjII24YMSEA=";
          # })
          (config.lib.vicinae.mkRayCastExtension {
            name = "base64";
            rev = "5c053bfacb80c561491668b644ba769d956aeed9";
            sha256 = "sha256-Z0w9trQNUC8bEZW+MCS3zjU3P5sN/rZc4xth0XkWhUU=";
          })
          # FIXME: broken build
          # (config.lib.vicinae.mkRayCastExtension {
          #   name = "bitwarden";
          #   rev = "b8c8fcd7ebd441a5452b396923f2a40e879565ba";
          #   sha256 = "sha256-N1zAPZJmmfvSw425MQDopSm/stu1IRI2t17xo8Ml+8g=";
          # })
          # (config.lib.vicinae.mkRayCastExtension {
          #   name = "claude";
          #   rev = "d9ec03d0ce2290682b8d03749c09807ff2c1e064";
          #   sha256 = "sha256-vSm64genQfBpLb541aqNkObi9Ri0T71nrw8wDFfM/Rc=";
          # })
          # (config.lib.vicinae.mkRayCastExtension {
          #   name = "conventional-commits";
          #   rev = "13e481b7e1a8393f5b7d3044c489d57ada298ce6";
          #   sha256 = "sha256-oyVMU2RfXuaaEk27/vOyCwYq4NNirksawrvG0ZBe47w=";
          # })
          # (config.lib.vicinae.mkRayCastExtension {
          #   name = "google-maps-search";
          #   rev = "542ed079c2eb5a95df0835d83ab1f1c2b1970e44";
          #   sha256 = "sha256-TNF6VzngV+SjUiZ6o7a3/uMSbfhnpiFFRfpphRGHHLY=";
          # })
          (config.lib.vicinae.mkRayCastExtension {
            name = "dad-jokes";
            rev = "5c053bfacb80c561491668b644ba769d956aeed9";
            sha256 = "sha256-KoyWzt7SWSOFMvt/efehbAq+MPJaN4dgiNfEhAgG8Mw=";
          })
          (config.lib.vicinae.mkRayCastExtension {
            name = "gif-search";
            rev = "5c053bfacb80c561491668b644ba769d956aeed9";
            sha256 = "sha256-lKlsPvPXc2gRL2lJjrVc4/RWDXoWlRVNK6PMgQJ7TMs=";
          })
          (config.lib.vicinae.mkRayCastExtension {
            name = "github";
            rev = "5c053bfacb80c561491668b644ba769d956aeed9";
            sha256 = "sha256-RX9m6YI4dDYtl00Fsy5Smbsyz46uxvIQXCaDDVapC0s=";
          })
          (config.lib.vicinae.mkRayCastExtension {
            name = "raycast-gemini";
            rev = "5c053bfacb80c561491668b644ba769d956aeed9";
            sha256 = "sha256-1rzx1NVlD6eM+cWUL5uSt349TMizJIkZBL5lfjGrdMk=";
          })
          (config.lib.vicinae.mkRayCastExtension {
            name = "tailwindcss";
            rev = "5c053bfacb80c561491668b644ba769d956aeed9";
            sha256 = "sha256-My6sweR59MuRTSELYE9biVOdwIIBoyKNoSJZehWSBK8=";
          })
          (config.lib.vicinae.mkRayCastExtension {
            name = "wikipedia";
            rev = "b8c8fcd7ebd441a5452b396923f2a40e879565ba";
            sha256 = "sha256-czA46UBAZwhOWoboab9n44zd+YkA74mUNg6zpQg3xxQ=";
          })
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          (config.lib.vicinae.mkRayCastExtension {
            name = "amphetamine";
            rev = "d480d47a5c3271f36134614ecdc49b2d447bccf2";
            sha256 = "sha256-DiAtPqcFWGNwBl2ZYXaDYBqIbD0yAevsHjL3YTbXGwI=";
          })
          (config.lib.vicinae.mkRayCastExtension {
            name = "brew";
            rev = "b8c8fcd7ebd441a5452b396923f2a40e879565ba";
            sha256 = "sha256-c0FdaXt24JF6cmjVd8aXQ6TrO5QiEJ4vt2DntAj9MlM=";
          })
        ];

      systemd = {
        enable = true;
      };
    };
  };
}
