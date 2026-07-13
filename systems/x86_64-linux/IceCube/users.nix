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
        ];
        shell = pkgs.fish;

        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCb/cyVAr89lBJUzEH2gjiDTP+JZJGECxlwQU9cUEuJ godtamit@BeastieMacBookV2"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINVma8utCSpsAs4XDWYESKGSs+Wc7PKtUspMUPaD36kn godtamit@IceCube"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELizHggQNC5IjYQfxXhnxIZRXWJ4iC0R/FIj5fbeX4A godtamit@Shaq"
        ];
      };

      jlh = {
        fullName = lib.godtamnix.decode "TGFuY2UgSGFzc29u";
        initialPassword = "password";
        isTrusted = true;
        extraGroups = [
          "nix"
          "systemd-journal"
          "docker"
          "podman"
        ];
        shell = pkgs.fish;

        authorizedKeys = [
          (lib.godtamnix.decode
            "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUg2Q1M5MG1WZXNLL2t0ZlNkcjN3bFJXK1A1QnBRTjVyRmpERWZ5WElWWWwgbGFuY2UuaGFzc29uQGdtYWlsLmNvbQ==")
        ];
      };
    };
  };
}
