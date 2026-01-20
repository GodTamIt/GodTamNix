{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.godtamnix.programs.graphical.desktop.hyprland;
in {
  options.godtamnix.programs.graphical.desktop.hyprland.enable = mkEnableOption "Hyprland";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprlock
      hypridle
      hyprshot
      gtk3
    ];

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        xwayland = {
          force_zero_scaling = true;
        };

        exec-once = [
          "waybar"
          "hypridle"
          "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
        ];

        env = [
          "XCURSOR_SIZE,32"
          "WLR_NO_HARDWARE_CURSORS,1"
          "GTK_THEME,Dracula"
        ];

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_rules = "";
          kb_options = "ctrl:nocaps";
          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
          };

          sensitivity = 0;
        };

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;
          "col.active_border" = "rgba(9742b5ee) rgba(9742b5ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        decoration = {
          #"col.shadow" = "rgba(1E202966)";
          #drop_shadow = true;
          #shadow_range = 60;
          #shadow_offset = "1 2";
          #shadow_render_power = 3;
          #shadow_scale = 0.97;
          rounding = 8;
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
          };
          active_opacity = 0.9;
          inactive_opacity = 0.6;
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {};

        #gestures = {
        #  workspace_swipe = false;
        #};

        # windowrule = [
        #  "float, file_progress"
        #  "float, confirm"
        #  "float, dialog"
        #  "float, download"
        #  "float, notification"
        #  "float, error"
        #  "float, splash"
        #  "float, confirmreset"
        #  "float, title:(Open File)"
        #  "float, title:branchdialog"
        #  "float, Lxappearance"
        #  "float, Wofi"
        #  "float, dunst"
        #  "animation none,Wofi"
        #  "float,viewnior"
        #  "float,feh"
        #  "float, pavucontrol-qt"
        #  "float, pavucontrol"
        #  "float, file-roller"
        #  "fullscreen, wlogout"
        #  "float, title:wlogout"
        #  "fullscreen, title:wlogout"
        #  "idleinhibit focus, mpv"
        #  "idleinhibit fullscreen, firefox"
        #  "float, title:^(Media viewer)$"
        #  "float, title:^(Volume Control)$"
        #  "float, title:^(Picture-in-Picture)$"
        #  "size 800 600, title:^(Volume Control)$"
        #  "move 75 44%, title:^(Volume Control)$"
        # ];

        windowrule = [
          "opacity 0.9 override 0.85 override, match:class firefox"
          "opacity 0.9 override 0.85 override, match:class antigravity"
          "opacity 0.9 override 0.85 override, match:class brave-browser"

          # Floating popups
          "float on, match:title ^(Open (File|Folder))$"
          "float on, match:title ^(Select (File|Folder))))$"

          # Workspace rules
          "workspace 2, match:class antigravity"
          "workspace 4, match:class ferdium"
          "workspace 4, match:class signal"
          "workspace 5, match:class firefox"
          "workspace 6, match:class (YouTube Music Desktop App)"

          # "opaque, class:(firefox)"
          # "workspace 1, class:^(Emacs)$"
          # "workspace 3, opacity 1.0, class:^(brave-browser)$"
          # "workspace 4, class:^(com.obsproject.Studio)$"
        ];

        "$mainMod" = "SUPER";
        "$shiftMod" = "SUPER SHIFT";

        bind = [
          "$mainMod, return, exec, antigravity"
          "$mainMod, t, exec, kitty"
          "$shiftMod, e, exec, kitty -e zellij_nvim"
          "$mainMod, o, exec, thunar"
          "$mainMod, Escape, exec, wlogout -p layer-shell"
          "$mainMod, Space, exec, vicinae toggle"
          "$mainMod, q, killactive"
          "$mainMod, M, exit"
          "$mainMod, F, fullscreen"
          "$mainMod, V, togglefloating"
          "$mainMod, D, exec, wofi --show drun --allow-images"
          "$shiftMod, S, exec, bemoji"
          "$mainMod, P, exec, wofi-pass"
          "$shiftMod, P, pseudo"
          "$mainMod, J, togglesplit"
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "$shiftMod, 1, movetoworkspace, 1"
          "$shiftMod, 2, movetoworkspace, 2"
          "$shiftMod, 3, movetoworkspace, 3"
          "$shiftMod, 4, movetoworkspace, 4"
          "$shiftMod, 5, movetoworkspace, 5"
          "$shiftMod, 6, movetoworkspace, 6"
          "$shiftMod, 7, movetoworkspace, 7"
          "$shiftMod, 8, movetoworkspace, 8"
          "$shiftMod, 9, movetoworkspace, 9"
          "$shiftMod, 0, movetoworkspace, 10"
          "$mainMod CONTROL, right, workspace, m+1"
          "$mainMod CONTROL, left, workspace, m-1"

          # Screenshot a window
          "$mainMod, PRINT, exec, hyprshot -m window"
          # Screenshot a monitor
          ", PRINT, exec, hyprshot -m output"
          # Screenshot a region
          "$shiftMod, PRINT, exec, hyprshot -m region"
        ];

        # Repeatable + locked
        binde = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ];

        # Locked
        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        # Mouse
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
