{inputs}: final: prev: let
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
  #          │                 Firefox Addon repository                 │
  #          ╰──────────────────────────────────────────────────────────╯
  firefox-addons = import inputs.firefox-addons {
    inherit (final) fetchurl;
    inherit (final) lib;
    inherit (final) stdenv;
  };

  #          ╭──────────────────────────────────────────────────────────╮
  #          │   From nixpkgs-unstable (faster updates but with cache)  │
  #          ╰──────────────────────────────────────────────────────────╯
  inherit
    (unstable)
    brave
    firefox
    google-chrome
    plex
    plex-desktop
    ytmdesktop
    zed-editor
    ;

  #          ╭──────────────────────────────────────────────────────────╮
  #          │ From nixpkgs-master (fast updating / want latest always) │
  #          ╰──────────────────────────────────────────────────────────╯
  inherit
    (master)
    wayle
    webull-desktop
    yaziPlugins
    yt-dlp
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
    pi
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
  signal-desktop = unstable.signal-desktop.overrideAttrs (oldAttrs: {
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

  # AutoRaise v5.3 (current in nixpkgs) uses the deprecated
  # NSApplicationActivateIgnoringOtherApps constant, which spams the build
  # log with a deprecation warning on macOS 14+. Upstream v5.6 passes 0
  # instead. Drop this override once nixpkgs ships autoraise >= 5.6.
  autoraise = let
    version = "5.6";
  in
    prev.autoraise.overrideAttrs (_old: {
      inherit version;
      src = final.fetchFromGitHub {
        owner = "sbmpost";
        repo = "AutoRaise";
        rev = "v${version}";
        hash = "sha256-DQyXHZPM/5rt6Vhmyhb/ienvk0ZXzg6zbVAmUYeaOVA=";
      };
    });

  # aquamarine = prev.aquamarine.overrideAttrs (_old: {
  #   src = prev.fetchFromGitHub {
  #     owner = "hyprwm";
  #     repo = "aquamarine";
  #     rev = "d67142c8c0966c94ecf88beddb14003256d8058c";
  #     hash = "sha256-XXrDUeITQvDtejcRqJUnSCyjlU8pSDuOIBOA40udnPs="; # The real hash
  #   };
  # });
}
