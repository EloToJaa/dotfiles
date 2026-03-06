# AGENTS.md

## Project Overview

This project is a Nix-based dotfiles and homelab management repository.

## Technology Stack

- **Nix**: Primary build system and package manager
  - Used for reproducible builds and deployments
  - Manages all system and user configurations

- **Clan.lol**: Infrastructure management and deployment tool
  - Used to deploy, build, and install configurations across machines
  - Manages homelab infrastructure and orchestration

## Project Structure

- `flake.nix` - Nix flake entry point and outputs
- `homeModules/` - Home-manager configurations for user environments
- `nixosModules/` - NixOS system configurations
- `machines/` - Per-machine configuration definitions
- `secrets/` - Encrypted secrets (managed via sops), depracated in favor of `sops/`
- `sops/` - SOPS (Secrets OPerationS) configuration
- `terranix/` - Infrastructure as code using Terranix (Terraform + Nix)

## Common Operations

### Building Configurations

```bash
clan machines build <machine>
```

### Deploying with Clan

```bash
clan machines update <machie>
```

### Updating Dependencies

```bash
nh os switch --update
```

## Secrets Management

Secrets are encrypted using SOPS (Secrets OPerationS) and decrypted at deployment time.
