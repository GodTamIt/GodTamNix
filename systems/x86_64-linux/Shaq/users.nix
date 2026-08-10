{
  pkgs,
  lib,
  ...
}: {
  godtamnix = {
    users = {
      godtamit = {
        fullName = lib.godtamnix.decode "Q2hyaXN0b3BoZXIgVGFt";
        initialPassword = "password";
        isTrusted = true;
        extraGroups = [
          "nix"
          "networkmanager"
          "systemd-journal"
          "lp"
          "tss"
          "power"
          "mpd"
          "docker"
          "podman"
          "kvm"
          "hermes"
        ];
        shell = pkgs.fish;

        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCb/cyVAr89lBJUzEH2gjiDTP+JZJGECxlwQU9cUEuJ godtamit@BeastieMacBookV2"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINVma8utCSpsAs4XDWYESKGSs+Wc7PKtUspMUPaD36kn godtamit@IceCube"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELizHggQNC5IjYQfxXhnxIZRXWJ4iC0R/FIj5fbeX4A godtamit@Shaq"
        ];
      };

      seank = {
        fullName = lib.godtamnix.decode "U2VhbiBLaG9zcm93c2hhaGk=";
        initialPassword = "password";
        isTrusted = true;
        extraGroups = [
          "nix"
          "networkmanager"
          "systemd-journal"
          "lp"
          "tss"
          "power"
          "mpd"
          "docker"
          "podman"
          "hermes"
        ];
        shell = pkgs.fish;
      };

      eddy = {
        fullName = lib.godtamnix.decode "RWRkeSBHaGFyYmk=";
        initialPassword = "password";
        isTrusted = true;
        extraGroups = [
          "nix"
          "networkmanager"
          "systemd-journal"
          "lp"
          "tss"
          "power"
          "mpd"
          "docker"
          "podman"
          "kvm"
          "hermes"
        ];
        shell = pkgs.zsh;

        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItT/UINDxVTp1p8Ijmhl/hCmDZ/y6DY0dkvkMiYJbZt eddy.gharbi.ca@gmail.com"
        ];
      };
    };
  };
}
