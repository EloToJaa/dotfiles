# Stalwart

## Authelia integration (deferred)

Integrating Stalwart with Authelia is on hold. nixpkgs (stable, unstable and master) ships Stalwart 0.15.5, and that version can't do Authelia single sign-on.

### What 0.15.5 supports

- The `oidc` directory (`crates/directory/src/backend/oidc`) is not the 1.x directory with `issuer-url` and `claim-username`. It takes `endpoint.url` and `endpoint.method` (`userinfo` or `introspect`) plus `fields.email`, `fields.username` and `fields.full-name`, and only checks OAUTHBEARER tokens. Every other login goes to the internal store with app passwords only (`with_only_app_pass(true)`), so IMAP, SMTP and webadmin password logins break.
- The webadmin only signs in through Stalwart's own OAuth server. It has no external IdP client (`oauthClientId` and `oauthScopes` arrived in 1.x).
- One directory (`storage.directory`) serves every protocol. `authentication.fallback-admin` works with any directory.

### Options

1. **Forward-auth on the webadmin.** Keep the internal directory and use `outputs.lib.homelab.mkForwardAuth` to put the webadmin paths (`/login`, `/manage`, `/settings`, `/api`) behind Authelia (admin group, two factors). JMAP, autoconfig, `/.well-known` and Stalwart's OAuth endpoints stay open for mail clients. Mail delivery and existing accounts don't change, but you still sign in to Stalwart after Authelia.
1. **LDAP directory through lldap.** Set `directory.lldap.type = "ldap"`, use template bind `uid=?,ou=people,dc=elotoja,dc=com`, and run lookups with a read-only bind user (`lldap_strict_readonly`). IMAP, SMTP and the webadmin then use lldap passwords, and recipients resolve. It needs:
   - lldap listening on server's Tailscale address instead of `127.0.0.1`
   - a bind user created by hand in lldap, with its password shared through a prompted Clan var
   - a custom lldap attribute mapped to `attributes.email-alias` (and added to `filter.email`), because users' `mail` is not an `@elotoja.com` address
   - existing internal accounts renamed to the lldap usernames, since principals are matched by name

   It doesn't add Authelia 2FA.

1. **The 0.15 OIDC directory.** Not worth it, for the reasons above.
1. **Wait for Stalwart 1.x in nixpkgs** (or package it in `pkgs/`). The `Oidc` directory with `issuerUrl` and webadmin login through a public PKCE client both need 1.x ([OIDC backend](https://stalw.art/docs/auth/backend/oidc/), [sign-in FAQ](https://stalw.art/docs/faq/sign-in/)). Even then, an OIDC directory can't check plaintext passwords (IMAP and SMTP need app passwords) or resolve recipients who have never signed in.

When this is picked up, add `auth.nix` with `modules.homelab.stalwart.auth.enable` modelled on `forgejo/auth.nix`: a shared `mkOidcSecret` generator and the client registered on the Authelia machine. Enable it in `machines/hbox/config.nix`.
