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
      kde = enabled;
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
    hostName = "Shaq";
    wireless = enabled;
    networkmanager = enabled;

    firewall = {
      enable = true;
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils

    fira-code
    nerd-fonts.fira-code
    noto-fonts

    elegant-sddm
  ];

  environment.sessionVariables = {
    # ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    fish = enabled;
    zsh = enabled;
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
    displayManager = {
      defaultSession = "plasma";

      sddm = {
        enable = true;

        theme = "${pkgs.elegant-sddm}/share/sddm/themes/Elegant";

        settings = {
          Users = {
            RememberLastSession = false;
          };
          Autologin = {
            # 'plasma' is typically the name for the Wayland session
            # Use 'plasmax11' if you are sticking to X11
            Session = "plasma";
          };
        };
        #wayland = {
        #  enable = true;
        #  compositor = "weston";
        #};
      };
    };

    ddclient = {
      enable = true;
      protocol = "cloudflare";
      usev4 = "webv4, webv4=checkip.dyndns.org";

      # The actual domain you want to update
      zone = lib.godtamnix.decode "YXN0LmxpdmU=";
      domains = [(lib.godtamnix.decode "c2hhcS5kZXYuYXN0LmxpdmU=")];

      username = "token";
      passwordFile = config.sops.secrets.cloudflare_api_token.path;

      # How often to check for an IP change (e.g., every 5 minutes)
      interval = "2min";
    };

    openssh = {
      enable = true;
      ports = [38888];

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };

      allowSFTP = true;
    };

    udisks2 = enabled;

    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  systemd = {
    # Disable any systemd sleep-like targets
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
