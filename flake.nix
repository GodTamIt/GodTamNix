{
  description = "GodTamNix";

  inputs = {
    # Core Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # System management
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Bridges home-manager-installed .app bundles into Spotlight/Launchpad/Dock
    # by trampolining them into ~/Applications/Home Manager Apps and
    # /Applications/Nix Apps. Without it, GUI apps from home-manager (kitty,
    # firefox, zed, etc.) only live in the nix store and are invisible to
    # macOS surfaces.
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Applications & packages
    anyrun-nixos-options = {
      url = "github:n3oney/anyrun-nixos-options";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypr-socket-watch = {
      url = "github:khaneliman/hypr-socket-watch";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    ssh-to-age = {
      url = "github:Mic92/ssh-to-age/v1.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    open-design = {
      url = "github:nexu-io/open-design/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      imports = [
        ./flake
      ];
    };
}
