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
    tstack = pkgs.ai-tstack-skills;
  };
  tstackSkills = lib.genAttrs [
    "babysit-pr"
    "council"
    "file-pr"
    "full-send"
    "full-stop"
    "leaving-pr-comments"
    "modernize"
    "sol-loop"
    "takeover"
  ] (name: "${upstreamSkills.tstack}/skills/${name}");
  piSkillFiles =
    lib.mapAttrs' (
      name: source:
        lib.nameValuePair ".pi/agent/skills/${name}" {inherit source;}
    )
    cfg;
in {
  config = {
    modules.ai.skills =
      {
        frontend-design = "${upstreamSkills.anthropic}/skills/frontend-design/";
        agent-browser = "${upstreamSkills.agent-browser}/skills/agent-browser/";
        grill-with-docs = "${upstreamSkills.matt}/skills/engineering/grill-with-docs";
      }
      // tstackSkills;

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
