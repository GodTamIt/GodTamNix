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
        "DP-5,3840x2160@144,0x0,1.5"
        "DP-6,3840x2160@144,3840x0,1.5"
      ];
      workspace = [
        "1, monitor:DP-5, default:true"
        "2, monitor:DP-5"
        "3, monitor:DP-5"
        "4, monitor:DP-6"
        "5, monitor:DP-5"
        "6, monitor:DP-6"
        "7, monitor:DP-6"
      ];
    };
  };
}
