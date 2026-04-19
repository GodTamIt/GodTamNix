{pkgs, ...}: {
  godtamnix = {
    users = {
      godtamit = {
        fullName = "Christopher Tam";
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
        ];
        shell = pkgs.fish;

        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQWgY055bGa/WPslldQ6Li/VGg8Zfvk1qqrJelLcJWZ godtamit@Chriss-MBP.local"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINVma8utCSpsAs4XDWYESKGSs+Wc7PKtUspMUPaD36kn godtamit@IceCube"
        ];
      };

      seank = {
        fullName = "Sean Khosrowshahi";
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
        ];
        shell = pkgs.fish;
      };
    };
  };
}
