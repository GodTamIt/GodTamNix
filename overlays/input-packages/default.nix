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
  # Backward-compatibility for deprecated stdenv attributes referenced by external modules
  stdenv =
    prev.stdenv
    // {
      isLinux = prev.stdenv.isLinux or prev.stdenv.hostPlatform.isLinux;
      isDarwin = prev.stdenv.isDarwin or prev.stdenv.hostPlatform.isDarwin;
      isx86_64 = prev.stdenv.isx86_64 or prev.stdenv.hostPlatform.isx86_64;
      isAarch64 = prev.stdenv.isAarch64 or prev.stdenv.hostPlatform.isAarch64;
      is64bit = prev.stdenv.is64bit or prev.stdenv.hostPlatform.is64bit;
    };

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
    pi-coding-agent
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
    agent-browser
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

  # Leave this until Antigravity IDE (likely upstream VSCode) adopts Electron 40+.
  # https://github.com/microsoft/vscode/issues/284464
  antigravity-ide = master.antigravity-ide.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];

    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        wrapProgram $out/bin/antigravity-ide \
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

  # aquamarine = prev.aquamarine.overrideAttrs (_old: {
  #   src = prev.fetchFromGitHub {
  #     owner = "hyprwm";
  #     repo = "aquamarine";
  #     rev = "d67142c8c0966c94ecf88beddb14003256d8058c";
  #     hash = "sha256-XXrDUeITQvDtejcRqJUnSCyjlU8pSDuOIBOA40udnPs="; # The real hash
  #   };
  # });
}
