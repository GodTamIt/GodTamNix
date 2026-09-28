{
  mkShell,
  pkgs,
  ...
}: let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [
      "clippy"
      "rust-analyzer"
      "rust-src"
      "rustfmt"
    ];
  };
in
  mkShell {
    packages = [rustToolchain];

    shellHook = ''
      echo "🔨 Rust DevShell"
      echo ""
      echo "📦 Rust toolchain: ${rustToolchain.version}"
      echo "  - rustc"
      echo "  - cargo"
      echo "  - clippy"
      echo "  - rustfmt"
      echo "  - rust-analyzer"
      echo "  - rust-src"
      echo ""
      echo "🦀 Ready for Rust development!"
    '';
  }
