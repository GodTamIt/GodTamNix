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
      monitor = [
        "DP-2, 3840x2160@144, 0x0, 1.5, vrr, 1, bitdepth, 10, cm, hdr"
        "DP-3, 3840x2160@144, 3840x0, 1.5, vrr, 1, bitdepth, 10, cm, hdr"
      ];
      workspace = [
        "1, monitor:DP-2, default:true"
        "2, monitor:DP-2"
        "3, monitor:DP-2"
        "4, monitor:DP-3"
        "5, monitor:DP-2"
        "6, monitor:DP-3"
        "7, monitor:DP-3"
      ];
    };
  };
}
