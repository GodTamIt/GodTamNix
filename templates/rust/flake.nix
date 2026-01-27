{
  description = "A Rust development template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    nixpkgs,
    rust-overlay,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
  in {
    packages = forEachSystem (system: {
      default = (pkgsFor system).callPackage ./default.nix {};
    });

    devShells = forEachSystem (system: {
      default = (pkgsFor system).callPackage ./shell.nix {};
    });
  };
}
