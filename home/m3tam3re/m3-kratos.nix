{config, ...}: {
  imports = [
    ../common
    ../features/cli
    ./home.nix
  ];

  features = {
    cli = {
      fish.enable = false;
    };
  };
}
