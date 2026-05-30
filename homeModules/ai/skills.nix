{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.skills;
  upstreamSkills = {
    anthropic = pkgs.callPackage ./pkgs/anthropics-skills.nix {};
    agent-browser = pkgs.callPackage ./pkgs/agent-browser-skills.nix {};
    matt = pkgs.callPackage ./pkgs/mattpocock-skills.nix {};
  };
  piSkillFiles =
    lib.mapAttrs' (
      name: source:
        lib.nameValuePair ".omp/agent/skills/${name}" {inherit source;}
    )
    cfg;
in {
  config = {
    modules.ai.skills = {
      frontend-design = "${upstreamSkills.anthropic}/skills/frontend-design/";
      agent-browser = "${upstreamSkills.agent-browser}/skills/agent-browser/";
      btca = ./skills/btca;
      grill-with-docs = "${upstreamSkills.matt}/skills/engineering/grill-with-docs";
    };

    home.packages = with pkgs; [
      llm-agents.agent-browser
      llm-agents.tuicr
    ];

    programs.opencode.skills = cfg;
    home.file = piSkillFiles;
  };
}
