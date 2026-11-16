{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.grok;
  token_path = osConfig.clan.core.vars.generators.anthropic.files.auth-token.path;
  toml = pkgs.formats.toml {};
  # the hub's API key is a secret: the wrapper reads it from the shared `anthropic`
  # clan vars generator at runtime so it stays out of the store
  package = pkgs.symlinkJoin {
    inherit (pkgs.llm-agents.grok) pname version meta;
    paths = [pkgs.llm-agents.grok];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      for bin in grok agent; do
        wrapProgram $out/bin/$bin \
          --run 'export HUB_API_KEY="$(cat ${token_path})"'
      done
    '';
  };
in {
  options.modules.ai.grok = {
    enable = lib.mkEnableOption "Enable Grok CLI module";
    models = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          model = lib.mkOption {
            type = lib.types.str;
            description = "Model id sent to the hub.";
          };
          name = lib.mkOption {
            type = lib.types.str;
            description = "Label shown in the model picker.";
          };
        };
      });
      default = {
        gpt-6-sol = {
          model = "gpt-6-sol";
          name = "GPT-6 Sol (hub)";
        };
        claude-sonnet = {
          model = "claude-sonnet-5-5";
          name = "Claude Sonnet 5.5 (hub)";
        };
      };
      description = "Models served by the hub, exposed to Grok through its OpenAI-compatible endpoint.";
    };
    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "gpt-6-sol";
      description = "Key in `models` used for new sessions.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [package];
    home.file.".grok/config.toml".source = toml.generate "grok-config.toml" {
      models.default = cfg.defaultModel;
      model =
        lib.mapAttrs (_: m: {
          inherit (m) model name;
          base_url = "https://hub.server.elotoja.com/v1";
          api_backend = "chat_completions";
          env_key = "HUB_API_KEY";
        })
        cfg.models;
    };
  };
}
