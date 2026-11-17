{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.grok;
  token_path = osConfig.clan.core.vars.generators.anthropic.files.auth-token.path;
  hub_url = "https://hub.server.elotoja.com/v1";
  toml = pkgs.formats.toml {};
  # the hub's API key is a secret: the wrapper reads it from the shared `anthropic`
  # clan vars generator at runtime and writes ~/.grok/auth.json (the format the
  # CLIProxyAPI docs describe), so it stays out of the store
  write_auth = pkgs.writeShellScript "grok-write-auth" ''
    key="$(cat ${token_path})"
    auth="''${GROK_HOME:-$HOME/.grok}/auth.json"
    mkdir -p "$(dirname "$auth")"
    (
      umask 077
      printf '{"xai::api_key":{"key":"%s","auth_mode":"api_key","create_time":"%s","user_id":"","email":null,"coding_data_retention_opt_out":true}}\n' \
        "$key" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$auth.tmp"
      mv "$auth.tmp" "$auth"
    )
    printf '%s' "$key"
  '';
  package = pkgs.symlinkJoin {
    inherit (pkgs.llm-agents.grok) pname version meta;
    paths = [pkgs.llm-agents.grok];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      for bin in grok agent; do
        wrapProgram $out/bin/$bin \
          --run 'export XAI_API_KEY="$(${write_auth})"'
      done
    '';
  };
in {
  options.modules.ai.grok.enable = lib.mkEnableOption "Enable Grok CLI module";

  config = lib.mkIf cfg.enable {
    home.packages = [package];
    # models are fetched from the hub's /v1/models, none are listed here
    home.file.".grok/config.toml".source = toml.generate "grok-config.toml" {
      features.remote_fetch = true;
      endpoints = {
        models_base_url = hub_url;
        models_list_url = "${hub_url}/models";
        # grok only trusts XAI_API_KEY on x.ai hosts or this URL; without it the key
        # probe fails and every run reports "Not signed in"
        xai_api_base_url = hub_url;
      };
      # the first listed model (claude-3-5-haiku) is not served by the hub (404)
      models.default = "grok-4.7";
    };
  };
}
