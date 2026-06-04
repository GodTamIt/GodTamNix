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

## Installation (NixOS)

The official NixOS ISO ships with flakes disabled. Enable them, clone the
repo, and provision the disk with `disko` before running `nixos-install`.

### 1. Boot the ISO and enable flakes

```bash
# Enable experimental features for this session
sudo mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

# Get online (skip if wired)
sudo systemctl start wpa_supplicant
# or: nmtui

# Disko only touches disks named in disks.nix, but double-check
# `lsblk` so you don't accidentally target the install medium.
```

### 2. Add a new host

For a brand-new machine, scaffold a host directory and generate its hardware
config from the live ISO:

```bash
# From the repo root
git clone <repo-url> godtamnix && cd godtamnix

# Generate hardware.nix for the new host (run on the target machine)
mkdir -p systems/x86_64-linux/<NewHost>
sudo nixos-generate-config --show-hardware-config \
  > systems/x86_64-linux/<NewHost>/hardware.nix
```

Then add the host's files:

- `systems/x86_64-linux/<NewHost>/disks.nix` — copy from an existing host and
  update `device` to the new disk's `/dev/disk/by-id/...` identifier
  (`ls -l /dev/disk/by-id/`).
- `systems/x86_64-linux/<NewHost>/users.nix` — user definitions.
- `systems/x86_64-linux/<NewHost>/default.nix` — system config, importing
  `disks.nix`, `hardware.nix`, `users.nix`, and `sops.nix`.
- `systems/x86_64-linux/<NewHost>/sops.nix` — reference
  `../../../secrets/<NewHost>/default.yaml`.
- `secrets/<NewHost>/default.yaml` — empty SOPS file (see step 3).

### 3. Wire up SOPS

Each host has its own age keypair. Add them to `.sops.yaml` under `keys:` and
add a `creation_rules` entry for the new path, then create an empty encrypted
secret file:

```bash
# Host key (on the new machine, after install) lives at /etc/sops/age/keys.txt
# User key lives at ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -o /tmp/host-key.txt
nix shell nixpkgs#age -c age-keygen -o /tmp/user-key.txt
grep -oE 'age1[0-9a-z]+' /tmp/host-key.txt
grep -oE 'age1[0-9a-z]+' /tmp/user-key.txt

# Create an empty encrypted file (the real values are decrypted at runtime)
sops --age "$(grep -oE 'age1[0-9a-z]+' /tmp/host-key.txt),$(grep -oE 'age1[0-9a-z]+' /tmp/user-key.txt)" \
  secrets/<NewHost>/default.yaml
```

To allow other machines to decrypt this host's secrets, append their public
age keys to the file with `sops updatekeys secrets/<NewHost>/default.yaml`.

### 4. Format with disko

Disko wipes and partitions the disk declaratively from `disks.nix`:

```bash
# WARNING: this destroys the target disk
sudo nix run github:nix-community/disko -- \
  --mode disko systems/x86_64-linux/<NewHost>/disks.nix
```

Verify the layout with `lsblk` and `mount` before continuing.

### 5. Install NixOS

```bash
sudo nixos-install --flake .#<NewHost> --no-root-passwd
# Set a root password when prompted (or pass --root-passwd)

# Copy the host's age key so the new install can decrypt secrets
sudo mkdir -p /etc/sops/age
sudo cp /tmp/host-key.txt /etc/sops/age/keys.txt
sudo chmod 600 /etc/sops/age/keys.txt

sudo reboot
```

After the first boot, log in as the configured user and copy their personal
age key, then re-key existing secrets for this host:

```bash
mkdir -p ~/.config/sops/age
cp /tmp/user-key.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Add this user as a recipient to other hosts' secret files
sops updatekeys secrets/IceCube/default.yaml
# ...repeat for any other host whose secrets this user should access
```

See `AGENTS.md` for full architecture and contribution guide.
