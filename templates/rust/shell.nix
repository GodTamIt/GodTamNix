{
  pkgs,
  mkShell,
  rust-bin,
}: let
  # Choose specific channel (stable, beta, or nightly)
  rustToolchain = rust-bin.stable.latest.default.override {
    extensions = ["rust-src" "rust-analyzer"];
  };
in
  mkShell {
    # Inherit build inputs from the main package
    inputsFrom = [(pkgs.callPackage ./default.nix {})];

    packages = [
      rustToolchain
      # pkgs.cargo-edit   # For 'cargo add'
      # pkgs.cargo-watch  # For 'cargo watch -x run'
      # pkgs.nil          # Nix Language Server
    ];
  }
