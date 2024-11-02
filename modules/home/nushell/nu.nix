{
  config,
  pkgs,
  ...
}: {
  programs.nushell = {
    enable = true;
    environmentVariables = {
      PROMPT_INDICATOR_VI_INSERT = "\"  \"";
      #PROMPT_INDICATOR_VI_NORMAL = "\"∙ \"";
      PROMPT_COMMAND = ''""'';
      PROMPT_COMMAND_RIGHT = ''""'';
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      SHELL = ''"${pkgs.nushell}/bin/nu"'';
      EDITOR = config.home.sessionVariables.EDITOR;
      VISUAL = config.home.sessionVariables.VISUAL;
    };
  };
}
