# GodTamNix — Repository Guide

A **NixOS + macOS (Darwin)** configuration managed as a Nix flake via `flake-parts`. Two platforms, multiple machines, multiple users, layered recursive module system.

**Core philosophy:** DRY, scoped, convention-driven. Inline one-off config; every reusable module gets a scope (global, user-shared, or user+machine).

---

## Directory Layout

`flake-parts` recursively auto-discovers modules — **no manual registry**. Adding a directory with a `default.nix` under `modules/`, `systems/`, `homes/`, etc. is enough (see **Git tracking** below).

```
flake.nix / flake/          # flake-parts wiring (configs, home, overlays, packages, apps, dev/)
lib/                        # Pure reusable functions → flake.lib / lib.godtamnix
├── file/                   #   importModulesRecursive, importDir, importSubdirs, scanDir, ...
├── module/                 #   enabled, disabled, mkOpt, mkModule, mkBoolOpt, ...
├── system/                 #   mkSystem (NixOS), mkDarwin, mkHome, common
├── theme/  base64/  btrfs/ #   theming/SCSS, base64, scrub helpers
modules/                    # Auto-discovered config modules
├── common/                 #   Shared NixOS + Darwin
├── nixos/  darwin/         #   Platform-specific system modules
└── home/                   #   Home Manager modules
systems/<arch>/<host>/      # Per-host system config (default, disks, hardware, users, sops)
homes/
├── users/<user>/           #   Cross-machine shared user config (base)
└── <arch>/<user>@<host>/   #   Machine-specific user overrides
secrets/<host>/             # SOPS (age) secrets — referenced via .sops.yaml
overlays/  packages/        # Dynamic overlay sources; custom packages (auto-imported)
templates/                  # Project scaffolding (c, cpp, go, node, python, rust, ...)
```

> **Note:** `systems/` is canonical. The root `hosts/` dir is unused/legacy — never add configs there.

---

## Scoping — where code lives

| Scope | Location |
|-------|----------|
| Global (all machines/users) | `lib/`, `modules/common/`, `modules/<platform>/suites/`, `overlays/`, `packages/`, `templates/` |
| Machine-specific system | `systems/<arch>/<host>/` (`default` boot/net/services, `disks` disko, `hardware` scan, `users`, `sops`) |
| Cross-machine user config | `homes/users/<user>/` (git, shell, base packages) |
| Per-machine user overrides | `homes/<arch>/<user>@<host>/` |

**Never** put user- or host-specific code in `modules/`. Home configs use **base + override**: import `../../users/<user>` for the shared base, then override per-machine.

**Composition order** (each builder in `lib/system/`): platform modules → host config (`systems/...`) → home config (`homes/...`).

---

## Option namespace

All custom options live under `godtamnix.*`, and the **directory structure mirrors the namespace**:

- `modules/home/programs/graphical/browsers/firefox/default.nix` → `godtamnix.programs.graphical.browsers.firefox`
- `modules/nixos/suites/development/default.nix` → `godtamnix.suites.development`

### Module shape

```nix
{lib, ...}: let
  inherit (lib.godtamnix) enabled;
in {
  options.godtamnix.<category> = {
    enable = lib.mkEnableOption "description";
  };

  config = lib.mkIf <category>.enable {
    # ...applied only when enabled
  };
}
```

Use the `enabled` helper to turn modules on (`godtamnix.nix = enabled;`); set `enable = true` (with sub-options) for conditional use.

---

## Library functions

All functions in `lib/` must be **pure** — no side effects, no file I/O during evaluation (except `builtins`), same inputs → same output. They take `inputs` and extract only what they need, and export via `flake.lib.<category>` in `lib/default.nix` (keep the export list sorted).

Import helpers: `lib.godtamnix.file.importModulesRecursive` (recursive), `importDir` (flat), `importSubdirs` (subdirectory files).

---

## Secrets

Managed via **sops-nix** (age), keys scoped per-host in `.sops.yaml`. To add a secret:

1. Add the path pattern to `.sops.yaml`.
2. Create `secrets/<hostname>/default.yaml` (SOPS-encrypted).
3. Reference via `config.sops.secrets.<name>` in the host config.

---

## Git tracking required (important)

Nix flakes read the working tree, **but the recursive filesystem walks only see git-tracked files**. After creating *any* new `default.nix`, secret, or config file, run `git add <path>` before re-evaluating — otherwise new modules silently don't exist and you'll hit errors like `The option 'godtamnix.<x>' does not exist`.

---

## Tooling

- **Formatter:** `alejandra` (via treefmt); **Nix linters:** `deadnix`, `statix` (plus many language formatters in `flake/dev/treefmt.nix`).
- **Typos:** `typos` (`.typos.toml`, excludes `secrets/`).
- **Pre-commit:** auto-generated `.pre-commit-config.yaml` via `git-hooks.nix`.
- **Dev shells:** `flake/dev/shells/<language>.nix` (`c`, `java`, `nix`, `python`, `rust`). Enter with `nix develop`.

---

## Key dependencies

`flake-parts` (orchestration), `home-manager` (user env), `nix-darwin` (macOS), `disko` (partitioning), `sops-nix` (secrets), `lanzaboote` (secure boot), `stylix` + `catppuccin` (theming), `hypr-socket-watch` (Hyprland IPC), `nix-flatpak`, `nix-index-database`.
