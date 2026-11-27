{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.skills;
  fromDir = dir: names: lib.genAttrs names (name: "${dir}/${name}");
  piSkillFiles =
    lib.mapAttrs' (
      name: source:
        lib.nameValuePair ".pi/agent/skills/${name}" {inherit source;}
    )
    cfg;
in {
  config = {
    modules.ai.skills =
      fromDir "${inputs.anthropic-skills}/skills" ["frontend-design"]
      // fromDir "${inputs.agent-browser-skills}/skills" ["agent-browser"]
      // fromDir "${inputs.mattpocock-skills}/skills/engineering" ["grill-with-docs"]
      // fromDir "${inputs.tstack-skills}/skills" [
        "babysit-pr"
        "council"
        "file-pr"
        "full-send"
        "full-stop"
        "leaving-pr-comments"
        "modernize"
        "sol-loop"
        "takeover"
      ];

    assertions =
      lib.mapAttrsToList (name: path: {
        assertion = builtins.pathExists path;
        message = "modules.ai.skills.${name}: ${toString path} does not exist";
      })
      cfg;

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
