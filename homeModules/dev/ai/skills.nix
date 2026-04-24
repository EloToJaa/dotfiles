{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.dev.ai.skills;
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  skills = {
    anthropic = pkgs.callPackage ./pkgs/anthropics-skills.nix {};
    agent-browser = pkgs.callPackage ./pkgs/agent-browser-skills.nix {};
  };
in {
  options.modules.dev.ai.skills = {
    enable = lib.mkEnableOption "Enable skills module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with aiTools; [
      agent-browser
    ];
    programs.opencode.skills = {
      frontend-design = "${skills.anthropic}/skills/frontend-design/";
      agent-browser = "${skills.agent-browser}/skills/agent-browser/";
    };
  };
}
