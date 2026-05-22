{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption nameValuePair types;

  cfg = config.modules.ai.skills;
  upstreamSkills = {
    anthropic = pkgs.callPackage ./pkgs/anthropics-skills.nix {};
    agent-browser = pkgs.callPackage ./pkgs/agent-browser-skills.nix {};
  };
  piSkillFiles =
    lib.mapAttrs' (
      name: source:
        nameValuePair ".pi/agent/skills/${name}" {inherit source;}
    )
    cfg.registry;
in {
  options.modules.ai.skills = {
    enable = mkEnableOption "Enable skills module";

    registry = mkOption {
      type = types.attrsOf (types.either types.path types.str);
      default = {};
      description = ''
        Shared agent skill registry. Add a skill here once and the enabled
        adapters expose it to opencode, pi, and future agents.
      '';
    };
  };

  config = mkIf cfg.enable {
    modules.ai.skills.registry = {
      frontend-design = "${upstreamSkills.anthropic}/skills/frontend-design/";
      agent-browser = "${upstreamSkills.agent-browser}/skills/agent-browser/";
    };

    home.packages = with pkgs; [
      llm-agents.agent-browser
      llm-agents.tuicr
    ];

    programs.opencode.skills = cfg.registry;
    home.file = piSkillFiles;
  };
}
