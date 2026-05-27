# GodTamNix — Repository Guide

## Overview

This is a **NixOS + macOS (Darwin)** system configuration managed as a Nix flake via `flake-parts`. It manages two platforms (NixOS and nix-darwin), multiple machines, and multiple users through a layered, recursive module system.

**Core philosophy:** DRY, scoped, convention-driven. Never create a module for one-off use — if it's only referenced in one place, inline it. Every module must have a scope: global, user-shared, or user+machine-specific.

---

## Directory Structure

```
.
├── flake.nix              # Flake entry: inputs, systems, flake-parts wiring
├── flake/                 # Flake-parts sub-module
│   ├── default.nix        # Imports lib, overlays, packages, configs, home, apps
│   ├── overlays.nix       # Dynamic overlay discovery + godtamnix packages
│   ├── packages.nix       # Package discovery from packages/
│   ├── configs.nix        # NixOS/Darwin configuration discovery
│   ├── home.nix           # Home Manager configuration discovery
│   ├── apps.nix           # Flake apps (update scripts)
│   └── dev/               # Dev partition (shells, checks, templates, treefmt)
├── lib/                   # Reusable Nix library functions
│   ├── base64/            # Base64 encode/decode
│   ├── file/              # File system ops (scanDir, importDir, importModulesRecursive, etc.)
│   ├── module/            # Module helpers (enabled, disabled, mkOpt, mkModule, etc.)
│   ├── system/            # System builders (mkSystem, mkDarwin, mkHome, common)
│   ├── theme/             # Theme utilities (color schemes, SCSS compilation)
│   └── overlay.nix        # Overlay helpers
├── modules/               # Configuration modules (recursive discovery)
│   ├── common/            # Shared across NixOS + Darwin
│   ├── nixos/             # NixOS-only modules
│   ├── darwin/            # macOS-only modules
│   └── home/              # Home Manager modules
├── systems/               # Per-host system configurations
│   ├── x86_64-linux/<host>/
│   └── aarch64-darwin/<host>/
├── homes/                 # Home Manager configurations
│   ├── users/<user>/      # Shared user config (cross-machine)
│   ├── x86_64-linux/<user>@<host>/
│   └── aarch64-darwin/<user>@<host>/
├── overlays/              # Dynamic overlay sources (input-packages/)
├── packages/              # Custom packages (imported automatically)
├── secrets/               # SOPS-encrypted secrets (per-host)
└── templates/             # Project templates (c, cpp, go, node, python, rust, etc.)
```

---

## Module System

### Recursive Discovery

Directories that contain a `default.nix` are automatically discovered and imported by `lib.file.importModulesRecursive`. **No manual registry is needed.** New modules are added by simply creating a new directory with a `default.nix` inside `modules/nixos/`, `modules/darwin/`, or `modules/home/`.

### Option Namespace

All custom configuration options live under `godtamnix.*`:

```nix
options.godtamnix.<category>.<subcategory> = {
  enable = lib.mkEnableOption "description";
  # optional sub-options...
};
```

Directory structure mirrors the option namespace. E.g.:
- `modules/home/programs/graphical/browsers/firefox/default.nix` → `godtamnix.programs.graphical.browsers.firefox`
- `modules/nixos/suites/development/default.nix` → `godtamnix.suites.development`

### System Builders

Three builders in `lib/system/` compose configurations:

| Builder | Purpose |
|---------|---------|
| `mkSystem` | NixOS `nixosSystem` with lanzaboote, sops-nix, disko, stylix, catppuccin, etc. |
| `mkDarwin` | macOS `darwinSystem` with sops-nix, stylix, home-manager |
| `mkHome` | `homeManagerConfiguration` with catppuccin, hypr-socket-watch, sops-nix |

Each builder recursively imports platform modules, then merges the host config and home config.

### Module Composition Order

1. **Platform modules** — `modules/common/`, `modules/nixos/` or `modules/darwin/`, `modules/home/`
2. **Host config** — `systems/<arch>/<hostname>/default.nix`
3. **Home config** — `homes/<arch>/<user>@<hostname>/default.nix`

---

## Scoping Model

Every piece of configuration has a scope. Use this hierarchy to decide where code lives:

```
Scope Hierarchy:
├── Global (all machines + users)
│   ├── lib/                    — Pure reusable functions
│   ├── modules/common/         — Shared NixOS + Darwin modules
│   ├── modules/nixos/suites/   — System-wide suites
│   ├── overlays/               — Package overlays
│   ├── packages/               — Custom packages
│   └── templates/              — Project templates
│
├── Machine-specific
│   ├── systems/<arch>/<host>/  — Host system config
│   │   ├── default.nix         — System-level settings
│   │   ├── disks.nix           — Disko partitioning
│   │   ├── hardware.nix        — Hardware scan (CPU, GPU, kernel)
│   │   ├── users.nix           — User definitions for this host
│   │   └── sops.nix            — SOPS secret references
│   └── secrets/<host>/         — Encrypted secrets
│
├── User-shared (cross-machine)
│   └── homes/users/<user>/     — Shared user config
│
└── User + Machine-specific
    └── homes/<arch>/<user>@<host>/  — Combined config
```

**Rules:**
- Put cross-machine shared config in `homes/users/<user>/`
- Put host-specific overrides in `homes/<arch>/<user>@<host>/`
- Put machine-level system config in `systems/<arch>/<host>/`
- Put secrets in `secrets/<host>/`
- Never put user-specific or host-specific code in `modules/`

---

## Code Style & Patterns

### Enable Pattern

Use the `enabled` helper for modules that should always be turned on:

```nix
let
  inherit (lib.godtamnix) enabled;
in
{
  godtamnix.nix = enabled;
  programs.fish = enabled;
}
```

For conditional enablement with sub-options:

```nix
godtamnix.suites.development = {
  enable = true;
  kubernetesEnable = true;
  dockerEnable = true;
};
```

### Module Structure

Every module should follow this shape:

```nix
{lib, ...}: let
  inherit (lib.godtamnix) enabled;
in {
  options.godtamnix.<category> = {
    enable = lib.mkEnableOption "description";
    # additional options...
  };

  config = lib.mkIf <category>.enable {
    # Applied only when enabled
  };
}
```

### Library Functions

All functions in `lib/` must be **pure**:
- No side effects
- Same inputs always produce same outputs
- No file I/O during evaluation (except via `builtins`)

Functions accept an `inputs` parameter and extract only what they need:

```nix
{inputs}: let
  inherit (inputs.nixpkgs.lib) mkOption types;
in {
  myFunction = arg1: arg2: /* pure implementation */;
}
```

Export via `flake.lib.<category>` in `lib/default.nix`. Keep-sorted the export list.

### Naming Conventions

- **Module files:** Always `default.nix`. Directories serve as namespace containers.
- **System configs:** `systems/<arch>/<hostname>/default.nix`
- **Home configs:** `homes/<arch>/<user>@<host>/default.nix`
- **Shared user configs:** `homes/users/<user>/default.nix`
- **Secrets:** `secrets/<hostname>/default.yaml`
- **Dev shells:** `flake/dev/shells/<language>.nix`

### Imports

Use `lib.godtamnix.file.importModulesRecursive` for recursive module discovery. Use `lib.godtamnix.file.importDir` for flat directory imports. Use `lib.godtamnix.file.importSubdirs` for importing files from subdirectories.

### Formatting & Linting

- **Formatter:** `alejandra` (via treefmt)
- **Linters:** deadnix, statix
- **Typos:** `typos` (configured in `.typos.toml`)
- **Pre-commit:** Managed by `git-hooks.nix` (auto-generated `.pre-commit-config.yaml`)

---

## Secrets

Secrets are managed via **sops-nix** with age-based encryption. Keys are configured per-host in `.sops.yaml`:

- `secrets/<hostname>/` — Encrypted secrets for that specific host
- Encryption keys are scoped to hosts in `.sops.yaml`

To add a secret:
1. Add the file path pattern to `.sops.yaml`
2. Create `secrets/<hostname>/default.yaml` (SOPS-encrypted)
3. Reference via `config.sops.secrets.<name>` in the host config

---

## Home Manager Architecture

Home configs follow a **base + override** pattern:

```nix
# homes/x86_64-linux/godtamit@Shaq/default.nix
{
  imports = [
    ../../users/godtamit  # Shared base config
  ];

  # Machine-specific overrides
  godtamnix.programs.graphical.browsers.brave = { enable = true; ... };
  wayland.windowManager.hyprland.settings.monitor = [ ... ];
}
```

This means:
1. `modules/home/` provides the base module definitions (auto-imported)
2. `homes/users/<user>/` provides shared user config (git, shell, base packages)
3. `homes/<arch>/<user>@<host>/` provides machine-specific overrides

---

## Adding New Modules

1. **Create the directory** under `modules/nixos/`, `modules/darwin/`, or `modules/home/`
2. **Write `default.nix`** with `options` and `config` following the pattern above
3. **Export any lib functions** in the appropriate `lib/<category>/` directory
4. **Use it** via `godtamnix.<category>.enable = true` in any host or home config

**Remember:** If the module is only used in one place, inline it. Don't create a directory for a one-off configuration.

---

## Adding New Machines

1. Create `systems/<arch>/<hostname>/` with:
   - `default.nix` — System settings (boot, networking, services, programs)
   - `disks.nix` — Disko partitioning
   - `hardware.nix` — Hardware scan
   - `users.nix` — User definitions for this host
   - `sops.nix` — SOPS secret references
2. Create `secrets/<hostname>/default.yaml` if needed
3. Create `homes/<arch>/<user>@<hostname>/` for each user on this host
4. Run `nix flake update` to pick up the new configuration

---

## Adding New Users

1. Add shared config to `homes/users/<username>/default.nix`
2. Add user definition to each host's `systems/<arch>/<hostname>/users.nix`
3. Create `homes/<arch>/<username>@<hostname>/` for machine-specific overrides

---

## Development

Dev tools are organized via the `dev` partition in `flake/dev/`:

- **Dev shells:** `flake/dev/shells/<language>.nix` — language-specific environments
- **Checks:** `flake/dev/checks.nix` — validation and test targets
- **Templates:** `flake/dev/templates.nix` — project scaffolding templates
- **Formatting:** `flake/dev/treefmt.nix` — unified formatting via treefmt

Use `nix develop` or `nix build#devShells.<system>.<name>` to enter a dev shell.

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| flake-parts | Flake orchestration |
| home-manager | User environment management |
| nix-darwin | macOS system configuration |
| disko | Disk partitioning/formatting |
| sops-nix | Secret management |
| lanzaboote | Secure boot (NixOS) |
| stylix | System-wide theming |
| catppuccin | Color theme integration |
| hypr-socket-watch | Hyprland IPC |
| nix-flatpak | Flatpak support |
| nix-index-database | Package search |
