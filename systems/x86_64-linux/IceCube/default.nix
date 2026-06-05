# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  imports = [
    # Include the results of the hardware scan.
    ./disks.nix
    ./hardware.nix
    ./sops.nix
    ./users.nix
  ];

  godtamnix = {
    # Enables core system configuration
    nix = enabled;

    suites = {
      audio = enabled;
      gaming = enabled;
    };

    system = {
      fonts = enabled;

      printing = enabled;
    };

    virtualisation = {
      podman = enabled;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot = enabled;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "IceCube";
    wireless = enabled;
    networkmanager = enabled;

    firewall = {
      enable = true;
      allowedTCPPorts = [48888];
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    usbutils

    fira-code
    nerd-fonts.fira-code
    noto-fonts
  ];

  environment.sessionVariables = {
    # ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
  };

  # Use catppuccin themed sddm
  catppuccin = {
    enable = true;
    sddm = {
      enable = true;
      flavor = "mocha";
      font = "Noto Sans";
      fontSize = "9";
      # background = "some/path";
      # userIcon = true;
    };
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    niri = enabled;
    fish = enabled;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services = {
    ddclient = {
      enable = true;
      protocol = "cloudflare";
      usev4 = "webv4, webv4=checkip.dyndns.org";

      # The actual domain you want to update
      zone = lib.godtamnix.decode "Z29kdGFtaXQuY29t";
      domains = [(lib.godtamnix.decode "aWNlY3ViZS5nb2R0YW1pdC5jb20=")];

      username = "token";
      passwordFile = config.sops.secrets.cloudflare_api_token.path;

      # How often to check for an IP change (e.g., every 5 minutes)
      interval = "2min";
    };

    displayManager = {
      sddm = {
        enable = true;
        # wayland.enable = true;
        # wayland.compositor = "weston";
      };
    };

    openssh = {
      enable = true;
      ports = [48888];

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };

      allowSFTP = true;
    };

    udisks2 = enabled;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
