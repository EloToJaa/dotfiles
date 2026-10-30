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

Defined in the `machines/flake-module.nix` inventory:

- `desktop` - Main desktop workstation (tag `desktop`)
- `laptop` - Laptop (tag `desktop`)
- `thinker` - Second laptop (tag `desktop`)
- `server` - Main homelab server: media, auth, monitoring and other services (tag `server`)
- `worker` - Build and CI host: Nixbot, Harmonia binary cache, T3 Code (tag `server`)
- `hbox` - Public VPS: Matrix, Forgejo, Stalwart mail (tag `server`)
- `miro` - Secondary homelab server: Home Assistant, Jellyfin, Blocky (tag `server`)

List them with `just hosts`. The `Justfile` also wraps building (`just build <host>...`) and deploying (`just deploy <host>...`).

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

# Neovim quickfix tests (need Python and Neovim on PATH)
python3 tests/review-quick-fixes.py
```

`nix flake check` builds every package and every host in the CI list in `ci/nixbot.nix`, so it is slow; prefer targeted builds while iterating.

## Code Style Guidelines

### Nix (.nix files)

**Formatting:**

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

Two mechanisms coexist:

- **Clan vars** (preferred for new machine secrets): declare a generator with `clan.core.vars.generators.<name>` and run `clan vars generate <machine>`. Public values land in `vars/per-machine/<machine>/` or `vars/shared/`; secret values are encrypted with Clan's SOPS backend, whose machine and user keys live in `sops/`.
- **sops-nix** (`secrets/secrets.yaml`): the `defaultSopsFile` for both `nixosModules/base/sops.nix` and `homeModules/home/sops.nix`. Edit with `sops secrets/secrets.yaml`. `.sops.yaml` encrypts files matching `secrets/[^/]+\.(yaml|json|env|ini)$` to the age key `age1n2ct0ecqtnhpcf8q27f0yvf6n3y0jjcuwer9rhxv9fqkfj0ktdfsycxfu0`.

Never commit plaintext secrets.

## Git Workflow

- Main branch: `main`
- Commits: `type(scope): description` (e.g. `feat(worker): ...`, `fix(dms): ...`); branches: `type/description`
- Nixbot builds the flake `checks` on every PR (see [CI/CD](#cicd))

## AI Agent Workflow

After making any code changes, AI agents **must** follow this verification sequence before declaring the task complete:

1. **Format** – Run `nix fmt` to apply formatting across all project files (Nix, Lua, Python, Shell, YAML, TOML, Markdown).
1. **Build** – Run the relevant build command for the changed configuration:
   - For machine changes: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
   - For packages: `nix build .#<package>`

Only proceed to the next step if the previous one succeeds.

## Common Patterns

### Adding a New Machine

1. Create directory in `machines/<name>/`
1. Add `configuration.nix` (Clan picks it up automatically); servers keep their `modules.homelab` service toggles in `config.nix`
1. Add `disko.nix` for disk partitioning and generate `facter.json` with `nixos-facter`
1. Add the machine to the `machines/flake-module.nix` inventory with its `deploy.targetHost` (Tailscale IP, see `tailscale status`) and tags
1. Add the host to the `checks` list in `ci/nixbot.nix` so CI builds it
1. Run `clan vars generate <name>` to create its keys and vars under `vars/per-machine/<name>/` and `sops/`

### Adding a Home Module

1. Create file in `homeModules/<category>/<name>.nix`
1. Export from `homeModules/<category>/default.nix`
1. Import in `homeModules/<category>/default.nix` if applicable
1. Follow existing module pattern with `options` and `config`

### Adding a Custom Package

1. Create package definition in `pkgs/<name>/default.nix` (or add to a group such as `pkgs/ai/` or `pkgs/yazi/`)
1. Add to `pkgs/pkgs.nix` exports
1. Update package versions using `nurl` or `nix-update`. Nixbot updates packages automatically unless they are listed in `unmanaged` in `ci/nixbot.nix`

## CI/CD

CI runs on [Nixbot](https://github.com/Mic92/nixbot), a self-hosted Hercules-CI-compatible service on `worker` (configured in `nixbot.toml` and `ci/nixbot.nix`; setup notes in `ci/README.md`):

- **Checks** - every PR builds the flake `checks`: all packages, the treefmt formatting check (`checks.treefmt`, the only formatting gate), and the toplevels of server, desktop, laptop, worker and hbox
- **Scheduled effects** - daily jobs update `flake.lock` and each package (`ci/update.sh`) and open `chore/update-*` PRs; those branches are deleted after merge

GitHub Actions in `.github/workflows/`:

- `auto-merge.yml` - Enables auto-merge on PRs labelled `dependencies` or `auto-merge`
