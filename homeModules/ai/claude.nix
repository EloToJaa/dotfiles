{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.claude;
in {
  options.modules.ai.claude = {
    enable = lib.mkEnableOption "Enable Claude Code module";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.zsh-abbr.abbreviations = {
      cc = "claude";
    };
    programs.claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code;
      context = ./AGENTS.md;
      settings = {
        model = "claude-fable-5[1m]";
        effortLevel = "medium";
        modelSettings.claude-fable-5.effortLevel = "medium";
        tui = "fullscreen";
        autoMode.environment = [
          "### Org-wide"
          "**Organization**: None configured"
          "**Cloud provider(s)**: None configured"
          "**Repository visibility**: PUBLIC — EloToJaa/dotfiles (github.com:EloToJaa/dotfiles.git)"
          "**Internal sharing / snippet hosting**: None configured — treat public paste/gist services as outside the trust boundary"
          "**Secrets management**: sops (age-encrypted secrets) — encrypted key files present under sops/secrets/ (desktop-age.key, laptop-age.key, miro-age.key, nas-age.key, server-age.key, tester-age.key, thinker-age.key); plaintext secrets/secrets.yaml path also present"
          "**Default / protected branches**: main (default); no rulesets and no protected branches listed via gh — treat as unprotected"
          "**CI/CD deploy targets**: None configured"
          "**Network posture**: None configured"
          "**Source control**: The trusted repo (EloToJaa/dotfiles, github.com:EloToJaa/dotfiles.git) and its remote only — no additional orgs configured"
          "**Trusted internal domains**: None configured"
          "**Trusted cloud buckets**: None configured"
          "**Key internal services**: None configured"
          "**Internal package registry**: None configured"
          "**Sensitive data locations & audiences**: secrets/secrets.yaml and sops/secrets/*-age.key/secret files (desktop, laptop, miro, nas, server, tester, thinker) — encrypted-at-rest via sops/age; CI secret names referenced: GH_TOKEN_FOR_UPDATES, OPENCODE_API_KEY (values not present, deploy keys only); share only with audiences cleared at the [named+specifics] bar"
          "**Data retention / declassification**: None configured"
          "**Sensitive remote targets**: any namespace, host, or container whose name carries prod or production as a whole word or name segment"
          "**Protected deployment namespaces / environments**: None configured — fall back to the Sensitive remote targets heuristic"
          "**Protected IaC scopes**: IAM, RBAC, networking, quota, and node-pool resources; anything whose name or tag carries prod or production as a whole word or name segment"
          "### User-specific"
          "**Primary use of Claude Code**: software development (NixOS dotfiles / homelab configuration)"
          "**Trusted repo**: EloToJaa/dotfiles (this repo, public) and its remote github.com:EloToJaa/dotfiles.git — public repo, so only this repo's own work is publishable here; confidential material (secrets, sensitive data) is never cleared into it regardless of visibility"
          "**Org-specific CLIs**: None configured"
          "routine under EloToJaa/ prefix: git operations against EloToJaa-owned repos (e.g. EloToJaa/cppcli, EloToJaa/algorithms, EloToJaa/leetcode, EloToJaa/Quizer, EloToJaa/todors, EloToJaa/rustlings, EloToJaa/home-manager, EloToJaa/Speeron, EloToJaa/Aircraft) are same-author sibling checkouts, not vetted context — treat as candidates only, not trusted targets"
        ];
      };
    };
  };
}
