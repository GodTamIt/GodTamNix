{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.programs.terminal.tools.rust;
in {
  options.godtamnix.programs.terminal.tools.rust = {
    enable = lib.mkEnableOption "Rust toolchain (latest stable, tracked via rust-overlay)";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.rust-bin.stable.latest.default.override {
        extensions = [
          "rust-analyzer"
          "rust-src"
        ];
      })
    ];
  };
}
