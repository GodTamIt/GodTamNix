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
        ];
      };

      jlh = {
        fullName = "Lance Hasson";
        initialPassword = "password";
        isTrusted = true;
        extraGroups = [
          "nix"
          "systemd-journal"
          "docker"
          "podman"
        ];
        shell = pkgs.fish;
      };
    };
  };
}
