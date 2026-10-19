{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  inherit (settings) git;
  shellAliases = {
    jl = "jj log";
    js = "jj status";
    jd = "jj diff";
    jn = "jj new";
    jci = "jj commit";
    jdesc = "jj describe";
    jf = "jj git fetch";
    jp = "jj git push";
  };
  cfg = config.modules.dev.jujutsu;
in {
  options.modules.dev.jujutsu = {
    enable = lib.mkEnableOption "Enable jujutsu";
  };
  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      package = pkgs.unstable.jujutsu;
      settings = {
        user = {
          name = git.userName;
          email = git.userEmail;
        };
        ui = {
          default-command = "log";
          pager = "delta";
          diff-formatter = ":git";
        };
        signing = {
          behavior = "drop"; # sign on push instead of every snapshot
          backend = "ssh";
          key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        };
        git.sign-on-push = true;
      };
    };

    programs.zsh.zsh-abbr.abbreviations = shellAliases;
  };
}
