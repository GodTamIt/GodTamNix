# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{lib, ...}: let
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

    hardware = {
      hid = enabled;
    };

    system = {
      fonts = enabled;

      printing = enabled;
    };

    virtualisation = {
      podman = enabled;
    };

    # services = {
    #   web = {
    #     nginx.enable = true;
    #     ddosProtection = true;

    #     vhosts = {
    #       jellyfin = {
    #         enable = true;
    #         domain = lib.godtamnix.decode "Y2hyaXNmbGl4LmdvZHRhbWl0LmNvbQ==";
    #       };
    #       nextcloud = {
    #         enable = true;
    #         domain = lib.godtamnix.decode "Y2xvdWQuZ29kdGFtaXQuY29t";
    #       };
    #       immich = {
    #         enable = true;
    #         domain = lib.godtamnix.decode "cGhvdG9zLmdvZHRhbWl0LmNvbQ==";
    #       };
    #     };
    #   };
    # };
  };

  # Let's Encrypt via Cloudflare DNS-01.
  # security.acme = {
  #   acceptTerms = true;
  #   defaults = {
  #     email = lib.godtamnix.decode "b2hnb2R0YW1pdEBnbWFpbC5jb20=";
  #     group = "nginx";
  #     reloadServices = ["nginx"];
  #     server = "https://acme-staging-v02.api.letsencrypt.org/directory";
  #     dnsProvider = "cloudflare";
  #     environmentFile = config.sops.secrets.cloudflare_acme_credentials.path;
  #     dnsPropagationCheck = true;
  #   };
  # };

  # Bootloader.
  boot.loader.systemd-boot = enabled;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "BeastieServerV2";
    networkmanager = enabled;

    firewall = {
      enable = true;
      allowedTCPPorts = [38888];
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
    niri = enabled;
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
    # ddclient = {
    #   enable = true;
    #   protocol = "cloudflare";
    #   usev4 = "webv4, webv4=checkip.dyndns.org";

    #   # The actual domain you want to update
    #   zone = lib.godtamnix.decode "Z29kdGFtaXQuY29t";
    #   domains = [
    #     (lib.godtamnix.decode "YmVhc3RpZXNlcnZlcnYyLmdvZHRhbWl0LmNvbQ==")
    #     (lib.godtamnix.decode "Y2hyaXNmbGl4LmdvZHRhbWl0LmNvbQ==")
    #     (lib.godtamnix.decode "cGhvdG9zLmdvZHRhbWl0LmNvbQ==")
    #     (lib.godtamnix.decode "Y2xvdWQuZ29kdGFtaXQuY29t")
    #   ];

    #   username = "token";
    #   passwordFile = config.sops.secrets.cloudflare_api_token.path;

    #   # How often to check for an IP change (e.g., every 5 minutes)
    #   interval = "2min";
    # };

    displayManager = {
      autoLogin = {
        enable = true;
        user = "godtamit";
      };

      sddm = {
        enable = true;
        # wayland.enable = true;
        # wayland.compositor = "weston";
      };
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
      group = "media";

      hardwareAcceleration = {
        enable = true;
        type = "vaapi";
        device = "/dev/dri/renderD128";
      };

      transcoding = {
        enableHardwareEncoding = true;
        hardwareDecodingCodecs = {
          av1 = true;
          h264 = true;
          hevc = true;
          hevc10bit = true;
        };
      };
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

    plex = {
      enable = true;
      openFirewall = true;
      group = "media";

      accelerationDevices = [
        "/dev/dri/renderD128"
      ];
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
