{
  imports = [
    ../common
    ./dotfiles
    ../features/cli
    ../features/desktop
    ./home.nix
  ];

  features = {
    cli = {
      fish.enable = true;
      fzf.enable = true;
      neofetch.enable = true;
    };
    desktop = {
      fonts.enable = true;
      hyprland.enable = true;
      wayland.enable = true;
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
          scale = 1.5;
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
          scale = 1.5;
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
        "4, monitor:DP-6"
        "5, monitor:DP-6"
        "6, monitor:DP-6"
        "7, monitor:DP-6"
      ];
    };
  };
}
