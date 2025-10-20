{
  pkgs,
  config,
  lib,
  ...
}: let
  shellAliases = {
    g = "git";
    gf = "onefetch --number-of-file-churns 0 --no-color-palette";
    ga = "git add";
    gaa = "git add --all";
    gs = "git status";
    gb = "git branch";
    gm = "git merge";
    gd = "git diff";
    gpl = "git pull";
    gplo = "git pull origin";
    gps = "git push";
    gpso = "git push origin";
    gpst = "git push --follow-tags";
    gcl = "git clone";
    gc = "git commit";
    gcm = "git commit -m";
    gcma = "git commit -am";
    gtag = "git tag -ma";
    gch = "git checkout";
    gchb = "git checkout -b";
    glog = "git log --oneline --decorate --graph";
    glol = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'";
    glola = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all";
    glols = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat";
  };
  cfg = config.modules.home.git;
in {
  options.modules.home.git = {
    enable = lib.mkEnableOption "Enable git";
  };
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.unstable.git;

      settings = {
        user = {
          name = config.modules.settings.git.userName;
          email = config.modules.settings.git.userEmail;
        };
        init.defaultBranch = "main";
        credential.helper = "store";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        pull.ff = "only";
        color.ui = true;
        url = {
          "https://github.com/EloToJaa/".insteadOf = "etj:";
          "https://github.com/".insteadOf = "gh:";
        };
      };

      signing = {
        signByDefault = false;
      };
    };

    programs.delta = {
      enable = true;
      package = pkgs.unstable.delta;
      options = {
        line-numbers = true;
        side-by-side = true;
        diff-so-fancy = true;
        navigate = true;
      };
    };

    home.packages = with pkgs.unstable; [gh]; # git-lfs

    programs = {
      zsh.shellAliases = shellAliases;
    };
  };
}
