# GodTamNix

Personal Nix flake managing NixOS (x86_64-linux) and nix-darwin (aarch64-darwin)
machines via `flake-parts`. Shared modules, per-host system configs, and
overridable per-user home-manager profiles.

## Structure

```
flake.nix          # Entry: inputs, flake-parts wiring
flake/             # Flake-parts sub-modules
lib/               # Reusable Nix lib: filesystem, module helpers, system builders, themes
modules/           # Configuration modules (auto-discovered)
  common/          # Shared NixOS + Darwin
  nixos/           # NixOS-only
  darwin/          # macOS-only
  home/            # Home Manager modules
systems/           # Per-host system configs
  x86_64-linux/    # NixOS hosts
  aarch64-darwin/  # macOS hosts
homes/             # Home Manager configs
  users/<user>/    # Cross-machine user config
  <arch>/<user>@<host>/  # Machine-specific overrides
packages/          # Custom packages
overlays/          # Package overlays
secrets/           # SOPS-encrypted secrets (per-host)
templates/         # Project scaffolding
```

## Secrets

Managed via [sops-nix](https://github.com/Mic92/sops-nix) with SSH-derived AGE
keys.

### Decrypting secrets

**Linux** (age key derived from SSH key, prompted for passphrase):

```bash
SOPS_AGE_KEY=$(systemd-ask-password | ssh-to-age -private-key -stdinpass -i ~/.ssh/id_ed25519) sops decrypt path/to/secret.yaml
```

**macOS** (age key derived from SSH key via Keychain):

```bash
security find-generic-password -w -s 'SSH Key Passphrase' | ssh-to-age -private-key -stdinpass -i ~/.ssh/id_ed25519
```

## Development

```bash
nix develop              # default dev shell
nix build .#devShells.<system>.<name>  # language-specific shells
nix flake check          # run all checks (pre-commit hooks, formatters, linters)
```

See `AGENTS.md` for full architecture and contribution guide.
