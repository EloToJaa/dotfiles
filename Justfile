set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

host_expr := 'builtins.concatStringsSep " " (builtins.attrNames (builtins.getFlake (builtins.toString ./.)).nixosConfigurations)'

# Show available recipes
default:
    @just --list

# List hosts available in this flake
hosts:
    @nix eval --raw --impure --expr '{{ host_expr }}'

# Format the codebase
format:
    nix fmt

# Check formatting without changing files
fmt-check:
    nix fmt -- --ci

# Run flake checks
flake-check:
    nix flake check

# Lint the codebase
lint: fmt-check flake-check
    just --fmt --check

# Build one or more hosts, e.g. `just build desktop laptop`
build +hosts:
    @for host in {{ hosts }}; do \
        echo "==> Building $host"; \
        nix build ".#nixosConfigurations.$host.config.system.build.toplevel"; \
    done

# Build all hosts
build-all:
    @for host in $(just hosts); do \
        echo "==> Building $host"; \
        nix build ".#nixosConfigurations.$host.config.system.build.toplevel"; \
    done

# Deploy one or more hosts, e.g. `just deploy desktop laptop`
deploy +hosts:
    @for host in {{ hosts }}; do \
        echo "==> Deploying $host"; \
        clan machines update "$host"; \
    done

# Deploy all hosts
deploy-all:
  clan machines update
