# Project Rules

## Nix Project Setup

I use Nix for development. Always set up a `flake.nix` when creating a new project.

- Use `flake-utils.lib.eachDefaultSystem` for per-system outputs.
- Provide a development shell with the tools appropriate to the project:
  - **C/C++:** Include a C/C++ compiler, `clang-tools` (`clangd`, `clang-format`), and `premake`.
  - **Go:** Include `go`, `gopls`, `gofumpt`, and `sqlc`.
  - **Rust:** Use `naersk` for builds and include `cargo`, `rustc`, `rustfmt`, `clippy`, and `rust-analyzer`.
  - **Python:** Use `uv2nix` and include `uv`, `ruff`, and `pyright`.
  - **JavaScript/TypeScript:** Use `bun2nix` and include `bun`, `oxlint`, `oxfmt`.

## Project Secrets

- Use SecretSpec with AWS Secrets Manager for project secrets.

## Frontend Preferences

- When a frontend is needed, prefer Svelte, with React as the second choice.
- Preferred web frameworks are Astro, SvelteKit, and TanStack Start.

## C/C++

- Use `clangd` for language support and `clang-format` for formatting.
- Prefer `premake` over CMake when feasible.

## Go

- Use `gopls` for language support and `gofumpt` for formatting.
- Use `sqlc` for SQL queries.
- Prefer the Go standard library for HTTP and other common functionality over third-party frameworks.

## JavaScript/TypeScript

- Use `effect` throughout the application, not only for error handling.

## Error Handling

- **Python:** Use `returns` for error handling.
- **Rust:** Use `thiserror` in library and domain code. Use `anyhow` in applications and top-level code.

## Git Naming Conventions

- Name commits `type(scope): changes description`, using types such as `feat`, `fix`, `chore`, `docs`, `refactor`, or `test`.
- The scope is optional: `docs: docs change description` is valid.
- Name branches `type/branch-description`, using the same types, for example `feat/add-login` or `fix/startup-error`.
