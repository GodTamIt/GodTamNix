{inputs}: final: _prev: let
  # citrix = import inputs.nixpkgs-citrix-workspace {
  #   inherit (final.stdenv.hostPlatform) system;
  #   inherit (final) config;
  # };
  master = import inputs.nixpkgs-master {
    inherit (final.stdenv.hostPlatform) system;
    inherit (final) config;
  };
  unstable = import inputs.nixpkgs-unstable {
    inherit (final.stdenv.hostPlatform) system;
    inherit (final) config;
  };
in {
  #          ╭──────────────────────────────────────────────────────────╮
  #          │                Citrix last known working                 │
  #          ╰──────────────────────────────────────────────────────────╯
  # inherit (citrix)
  #   citrix_workspace
  #   ;

  #          ╭──────────────────────────────────────────────────────────╮
  #          │                 Firefox Addon repository                 │
  #          ╰──────────────────────────────────────────────────────────╯
  firefox-addons = import inputs.firefox-addons {
    inherit (final) fetchurl;
    inherit (final) lib;
    inherit (final) stdenv;
  };

  #          ╭──────────────────────────────────────────────────────────╮
  #          │ From nixpkgs-master (fast updating / want latest always) │
  #          ╰──────────────────────────────────────────────────────────╯
  inherit
    (master)
    claude-code
    gemini-cli
    opencode
    yaziPlugins
    yt-dlp
    ytmdesktop
    ;

  # Leave this until Antigravity (likely upstream VSCode) adopts Electron 40+.
  # https://github.com/microsoft/vscode/issues/284464
  antigravity = master.antigravity.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];

    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        wrapProgram $out/bin/antigravity \
          --append-flags "--disable-features=WaylandWpColorManagerV1"
      '';
  });

  # Leave this until Signal adopts Electron 40+.
  signal-desktop = master.signal-desktop.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];
    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        wrapProgram $out/bin/signal-desktop \
          --append-flags "--disable-features=WaylandWpColorManagerV1"
      '';
  });

  # python3 = _prev.python3.override {
  #   packageOverrides = _pyFinal: _pyPrev: {
  #     # TODO: remove after hitting channel
  #     inherit (master.python3Packages) fastmcp mcp;
  #   };
  # };
  #
  # python3Packages = final.python3.pkgs;

  #          ╭──────────────────────────────────────────────────────────╮
  #          │   From nixpkgs-unstable (reasonable update / stability   │
  #          │                         balance)                         │
  #          ╰──────────────────────────────────────────────────────────╯
  inherit
    (unstable)
    # Misc
    _1password-gui
    # Online services to keep up to date
    element-desktop
    teams-for-linux
    ;

  # aquamarine = prev.aquamarine.overrideAttrs (old: {
  #   src = prev.fetchFromGitHub {
  #     owner = "gulafaran";
  #     repo = "aquamarine";
  #     rev = "1f1ba1e79b6a90780d437b8cea4d0967d2333211";
  #     hash = "sha256-XXrDUeITQvDtejcRqJUnSCyjlU8pSDuOIBOA40udnPs="; # The real hash
  #   };
  # });
}
