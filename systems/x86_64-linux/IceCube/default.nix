# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.godtamnix) enabled;
in {
  imports = [
    # Include the results of the hardware scan.
    ./disks.nix
    ./hardware-configuration.nix
    ./users.nix
  ];

  godtamnix = {
    # Enables core system configuration
    nix = enabled;

    suites = {
      audio = enabled;
      gaming = enabled;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot = enabled;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "IceCube";
    wireless = enabled;
    networkmanager = enabled;
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
    fira-code
    nerd-fonts.fira-code
    noto-fonts
  ];

  environment.sessionVariables = {
    # ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
  };

  services.displayManager.sddm = {
    enable = true;
    #wayland = {
    #  enable = true;
    #  compositor = "weston";
    #};
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

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
