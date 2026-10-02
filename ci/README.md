# Nixbot update automation

The server opts into `modules.homelab.nixbot`. The upstream NixOS module provides
Nixbot, PostgreSQL, systemd credentials, a Unix socket and its nginx proxy. The
proxy uses the existing `server.elotoja.com` wildcard certificate at
`https://nixbot.server.elotoja.com`. No deployment is performed by this change.

The service remains disabled until real GitHub App/OAuth IDs have been generated.
This lets the configuration build without inventing credentials. Public IDs are
stored as Clan public variables; the PEM, OAuth secret and generated webhook
secret are encrypted by Clan's SOPS backend and loaded with systemd credentials.

## External setup

Follow [Nixbot's GitHub App guide](https://github.com/Mic92/nixbot/blob/main/docs/GITHUB.md):

1. Create an App for EloToJaa. Set its homepage to
   `https://nixbot.server.elotoja.com`, active webhook to
   `https://nixbot.server.elotoja.com/webhooks/github`, and OAuth callback to
   `https://nixbot.server.elotoja.com/auth/github/callback`.
2. Grant repository Contents, Pull requests and Checks read/write, Metadata and
   Issues read. Subscribe to Push, Pull request, Check run, Check suite and Issue
   comment. Install it **only** on `EloToJaa/dotfiles`. Enable user authorization
   and generate its OAuth client secret and PEM key.
3. Run `clan vars generate server --generator nixbot-github`. Supply the App ID,
   OAuth client ID, the PEM encoded with `base64 -w0`, and OAuth secret. Do not
   commit unencrypted secrets. Set the generated webhook secret in the App
   settings (retrieve it privately with Clan's vars tooling). Regenerating this
   generator rotates the webhook secret; update the App settings accordingly.
4. Commit the public variables and encrypted secret outputs, rerun formatting and
   the server build, and deploy separately when ready. Ensure public DNS and the
   existing ingress route reach the server's nginx. This PR does not deploy.
5. Sign in as `EloToJaa` and enable the discovered repository in Nixbot's UI. The
   service allowlist is restricted to `EloToJaa/dotfiles`. Configure required
   GitHub status checks after the first successful build.

No PAT or per-repository effect secret is needed: `git.type = "GitToken"` obtains
an App installation token and `checkout = true` supplies an authenticated,
pushable checkout. Effects run only on the default branch, never on PRs.

## Scheduled updates and validation

At 03:00 UTC, independent effects update each package exported by `pkgs/pkgs.nix`
(and all Yazi plugin/theme and AI skill/extension packages in `pkgs/yazi` and
`pkgs/ai`, explicitly exported by `pkgs/pkgs.nix`)
(except Yamtrack, handled by its source input) and each tagged input below the
`# update` comment: `clan-core`, `hermes-agent`, `bun2nix`, and `yamtrack-src`. Each has its own
lock, branch and PR; an individual failure does not prevent the others running.
Unchanged updates do not create PRs or rewrite an identical existing PR tree.
Updates require successful `nix fmt` and package builds (or all three host builds
for Clan/Hermes/Bun2nix inputs) before publishing. Bun2nix input updates also build
Streamystats to validate its Bun dependencies and build hooks. Streamystats regenerates `bun.nix`;
Yazi and AI skill packages follow their upstream default branch revisions.
Yamtrack's package version and changelog follow its source tag. Dreame updates are
restricted to stable `v2.*.*` release tags; v1 releases and betas are excluded.
Hermes, Bun2nix and Yamtrack select numeric stable release tags. Clan currently publishes
numeric release branches (`26.05`), not release tags: its updater selects the
latest numeric release branch. Development branches and demo tags are excluded.

At 02:00 UTC, a separate effect runs `nix flake update` without input arguments to
refresh all locked inputs, replacing the removed GitHub Actions lock updater.
It maintains one `chore/update-flake-lock` branch and PR titled
`chore: update flake.lock`, requiring formatting and server, desktop and laptop
builds before publishing. Unchanged locks do not create PRs. It keeps the input
URLs in `flake.nix`; the 03:00 release effects select newer release references and
lock those individual inputs. No submodule update is scheduled. Review every
automated PR before merging.

## Pull request CI

Every PR builds the `desktop`, `laptop` and `server` system checks alongside all
exported package checks selected by `attribute = "checks"` in `nixbot.toml`.
Nixbot publishes GitHub checks with build status and links to its build logs.
The GitHub App must have Checks read/write permission and receive Pull request
webhooks, as described above.

Nixbot also evaluates the PR's effect definitions and builds their dependencies,
including both scheduled update groups. These validations contribute to the
GitHub effects status. `effects_on_pull_requests = false` keeps the update
scripts from executing on PRs while allowing this validation.

When a PR closes without merging, Nixbot cancels its unfinished work, removes
pending approval requests and supersedes queued changes. On merge it preserves
the PR build so the default-branch push can reuse the same tree. Nixbot's normal
retention cleanup removes old build records and logs; periodic repository cleanup
prunes stale PR refs and orphaned worktrees.
There are no PR preview deployments or other PR resources requiring a custom
`pull_request_closed` teardown effect.

The old GitHub Actions host-build workflow was removed. Successful CI builds
validate configuration; GitHub checks, close/merge handling, scheduled effects
and service runtime require external setup and deployment before they can be
tested end to end.
