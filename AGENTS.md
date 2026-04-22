# AGENTS.md

## Project Overview

This is a Nix-based dotfiles and homelab management repository using Clan.lol for infrastructure orchestration. It manages NixOS systems, home-manager configurations, and secrets across multiple machines.

## Technology Stack

- **Nix/NixOS**: Primary build system and package manager (flakes-based)
- **Clan.lol**: Infrastructure management and deployment (`nixos-anywhere`, `disko`, `nixos-facter`)
- **Home Manager**: User environment configuration
- **SOPS**: Secrets management with age encryption
- **flake-parts**: Modular flake composition

## Build/Development Commands

### Building and Deploying

```bash
# Build a machine configuration
nix build .#nixosConfigurations.<machine>.config.system.build.toplevel

# Build a package
nix build .#<package>

# Deploy configuration to a machine
clan machines update <machine>

# Update system with nh (Nix Helper)
nh os switch

# Format all project files with treefmt
nix fmt
```

### Available Machines

- `desktop` - Main desktop workstation
- `laptop` - Laptop configuration
- `server` - Homelab server
- `nas` - NAS/storage server
- `miro` - Additional machine
- `tester` - Testing environment

### Testing/Linting

```bash
nix build .#nixosConfigurations.<host>.config.system.build.toplevel

# Format all files (Nix, Lua, Python, Shell, YAML, TOML, Markdown)
nix fmt

# Verify formatting in CI mode (exits 1 if unformatted)
nix fmt -- --ci

# Check flake evaluation and formatting
nix flake check

# Lint Lua files (for Neovim configs)
luacheck <file>
```

## Project Structure

```
├── flake.nix              # Flake entry point
├── settings.nix           # Shared settings module (username, email, etc.)
├── overlays.nix           # Nixpkgs overlays
├── machines/              # Per-machine configurations
│   ├── flake-module.nix   # Machine definitions for clan
│   ├── desktop/
│   ├── laptop/
│   └── server/
├── homeModules/           # Home-manager modules
│   ├── home/              # Home configuration
│   ├── desktop/           # Desktop environment
│   ├── dev/               # Development tools
│   └── cybersec/          # Security tools
├── nixosModules/          # NixOS system modules
│   ├── base/              # Base system configuration
│   ├── core/              # Core system features
│   └── homelab/           # Homelab services
├── pkgs/                  # Custom packages
├── sops/                  # SOPS secrets configuration
├── terranix/              # Infrastructure as code (Terraform)
└── vars/                  # Clan variables
```

## Code Style Guidelines

### Nix (.nix files)

**Formatting:**

- Indentation: 2 spaces
- Line length: ~100 characters (soft limit)
- Use `let ... in` for local variable bindings
- Use `inherit` to bring values into scope

**Module Structure:**

```nix
{lib, ...}: {
  options.modules.<name> = {
    enable = lib.mkEnableOption "description";
    optionName = lib.mkOption {
      type = lib.types.str;
      default = "value";
      description = "Option description";
    };
  };

  imports = [
    ./submodule.nix
  ];
}
```

**Naming Conventions:**

- Module options: `modules.<category>.<name>`
- Enable options: `enable` (within the module namespace)
- Variables: `snake_case` or `camelCase` (prefer `snake_case` in Nix)
- Constants: `UPPER_CASE` for special values
- Function parameters: Destructure with `{lib, config, pkgs, ...}:`

**Imports and Dependencies:**

- Always include `lib` as first parameter
- Use `inherit (lib) mkOption mkEnableOption types;` for frequently used functions
- Follow inputs with `inputs` attribute for flake inputs
- Use `specialArgs` to pass additional arguments to modules

**Comments:**

- Inline comments after option definitions: `# brief description`
- Avoid redundant comments that repeat the code
- Use comments for non-obvious behavior or rationale

### Python

**Formatting:**

- Indentation: 4 spaces
- Line length: 88 characters (Black default)
- 2 blank lines between top-level functions
- 1 blank line between methods

**Type Hints:**

- Use type hints for function parameters and return types
- Use `|` for union types (Python 3.10+): `str | None`

**Style:**

```python
def function_name(param: str) -> tuple[str | None, str | None]:
    """Brief docstring."""
    if condition:
        return None, None
    return value1, value2
```

### Lua (Neovim configs)

**Formatting:**

- Use `stylua.toml` configuration
- Indentation: 2 spaces
- Sort requires alphabetically
- Collapse simple statements for functions only

**Linting:**

- Use `luacheck` with `.luacheckrc`
- Globals: `vim`, `Status`, `Header`, `ui`, `cx`, `ya`

## Secrets Management

- Secrets are encrypted using SOPS (Secrets OPerationS) with age
- Key location: `age1n2ct0ecqtnhpcf8q27f0yvf6n3y0jjcuwer9rhxv9fqkfj0ktdfsycxfu0`
- Pattern: `secrets/[^/]+\.(yaml|json|env|ini)$`
- Store in `sops/` directory (not `secrets/` which is deprecated)
- Never commit plaintext secrets

## Git Workflow

- Main branch: `main`
- Use meaningful commit messages
- CI builds all machine configurations on PRs affecting `flake.lock`
- Supported hosts: server, desktop, laptop

## Common Patterns

### Adding a New Machine

1. Create directory in `machines/<name>/`
1. Add `default.nix` with machine-specific configuration
1. Add `disko.nix` for disk partitioning (if needed)
1. Add to `machines/flake-module.nix` inventory
1. Generate SSH host keys in `vars/per-machine/<name>/`

### Adding a Home Module

1. Create file in `homeModules/<category>/<name>.nix`
1. Export from `homeModules/<category>/default.nix`
1. Import in `homeModules/<category>/default.nix` if applicable
1. Follow existing module pattern with `options` and `config`

### Adding a Custom Package

1. Create package definition in `pkgs/<name>.nix`
1. Add to `pkgs/pkgs.nix` exports
1. Update package versions using `nurl` or `nix-update`

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- `build.yml` - Builds all machine configurations
- `format-check.yml` - Verifies all files are formatted with treefmt
- `update-flake-lock.yml` - Updates flake.lock automatically
- `opencode.yml` - OpenCode integration
