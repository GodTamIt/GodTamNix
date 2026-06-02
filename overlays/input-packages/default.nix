{inputs}: final: prev: let
  # citrix = import inputs.nixpkgs-citrix-workspace {
  #   inherit (final.stdenv.hostPlatform) system;
  #   inherit (final) config;
  # };
  master = import inputs.nixpkgs-master {
    inherit (final.stdenv.hostPlatform) system;
    inherit (final) config;
  };
in {
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
    plex-desktop
    wayle
    webull-desktop
    yaziPlugins
    yt-dlp
    ytmdesktop
    zed-editor
    ;

  #          ╭──────────────────────────────────────────────────────────╮
  #          │          From llm-agents (AI tools repository)           │
  #          ╰──────────────────────────────────────────────────────────╯
  inherit
    (inputs.llm-agents.packages.${final.stdenv.hostPlatform.system})
    claude-code
    gemini-cli
    oh-my-opencode
    opencode
    rtk
    ;

  #          ╭──────────────────────────────────────────────────────────╮
  #          │        From ssh-to-age (AGE key derivation from SSH)     │
  #          ╰──────────────────────────────────────────────────────────╯
  inherit
    (inputs.ssh-to-age.packages.${final.stdenv.hostPlatform.system})
    ssh-to-age
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

  # OpenLDAP is failing tests so skip them:
  # https://github.com/NixOS/nixpkgs/issues/514113
  openldap = prev.openldap.overrideAttrs {
    doCheck = false;
  };

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

  # aquamarine = prev.aquamarine.overrideAttrs (_old: {
  #   src = prev.fetchFromGitHub {
  #     owner = "hyprwm";
  #     repo = "aquamarine";
  #     rev = "d67142c8c0966c94ecf88beddb14003256d8058c";
  #     hash = "sha256-XXrDUeITQvDtejcRqJUnSCyjlU8pSDuOIBOA40udnPs="; # The real hash
  #   };
  # });
}
