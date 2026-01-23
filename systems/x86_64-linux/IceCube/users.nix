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
      };
    };
  };
}
