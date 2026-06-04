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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCb/cyVAr89lBJUzEH2gjiDTP+JZJGECxlwQU9cUEuJ godtamit@BeastieMacBookV2"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINVma8utCSpsAs4XDWYESKGSs+Wc7PKtUspMUPaD36kn godtamit@IceCube"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELizHggQNC5IjYQfxXhnxIZRXWJ4iC0R/FIj5fbeX4A godtamit@Shaq"
        ];
      };
    };
  };
}
