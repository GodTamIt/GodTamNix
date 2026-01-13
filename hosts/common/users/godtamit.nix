{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.godtamit = {
    initialHashedPassword = "$y$j9T$eNVfw7M7DpxcTWqOVXdpq0$y4k0vOda.qSo1fPj4QVMuMYMcJ8Twy9uiyu9gh5Z4b3";
    isNormalUser = true;
    description = "godtamit";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
    ];
    packages = [inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
  home-manager.users.godtamit =
    import ../../../home/godtamit/${config.networking.hostName}.nix;
}
