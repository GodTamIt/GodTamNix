{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.godtamnix.nix;
in {
  imports = [(lib.getFile "modules/common/nix/default.nix")];

  options.godtamnix.nix = {
    enable = lib.mkEnableOption "Nix settings";
  };

  config = mkIf cfg.enable {
    # On macOS we install Nix via the Determinate Systems installer, which
    # owns /etc/nix/nix.conf, the launchd daemon, and the _nixbld users.
    # nix-darwin must NOT try to manage any of that — otherwise activation
    # tries to delete the nixbld users/group and refuses ("would break nix").
    #
    # Settings normally configured here (nix.gc, nix.settings.substituters,
    # etc.) need to live in Determinate's config instead:
    #   /etc/nix/nix.custom.conf      (substituters, experimental-features, …)
    #   ~/.config/nix/nix.conf        (per-user overrides)
    nix.enable = false;
  };
}
