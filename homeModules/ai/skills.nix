{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.skills;
  upstreamSkills = {
    anthropic = pkgs.ai-anthropics-skills;
    agent-browser = pkgs.ai-agent-browser-skills;
    matt = pkgs.ai-mattpocock-skills;
    open-code-review = pkgs.ai-open-code-review-skills;
  };
  piSkillFiles =
    lib.mapAttrs' (
      name: source:
        lib.nameValuePair ".pi/agent/skills/${name}" {inherit source;}
    )
    cfg;
in {
  config = {
    modules.ai.skills = {
      frontend-design = "${upstreamSkills.anthropic}/skills/frontend-design/";
      agent-browser = "${upstreamSkills.agent-browser}/skills/agent-browser/";
      grill-with-docs = "${upstreamSkills.matt}/skills/engineering/grill-with-docs";
      open-code-review = "${upstreamSkills.open-code-review}/skills/open-code-review/";
    };

    home.packages = with pkgs; [
      llm-agents.agent-browser
      llm-agents.hunk
    ];

    programs = {
      codex.skills = cfg;
      claude-code.skills = cfg;
      opencode.skills = cfg;
    };
    home.file = piSkillFiles;
  };
}
