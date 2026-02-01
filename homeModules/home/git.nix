{
  pkgs,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) git;
  shellAliases = {
    g = "git";
    gf = "onefetch --number-of-file-churns 0 --no-color-palette";
    ga = "git add";
    gaa = "git add --all";
    gs = "git status";
    gb = "git branch";
    gm = "git merge";
    gd = "git diff";
    gp = "git pull";
    gpo = "git pull origin";
    gP = "git push";
    gPo = "git push origin";
    gPt = "git push --follow-tags";
    gC = "git clone";
    gc = "git commit";
    gcm = "git commit -m";
    gcam = "git commit -am";
    gtag = "git tag -ma";
    gch = "git checkout";
    gchb = "git checkout -b";
    glg = "serie";
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
    programs = {
      git = {
        enable = true;
        package = pkgs.unstable.git;

        settings = {
          user = {
            name = git.userName;
            email = git.userEmail;
          };
          init.defaultBranch = "main";
          credential.helper = "store";
          merge.conflictStyle = "diff3";
          diff.colorMoved = "default";
          pull.ff = "only";
          color.ui = true;
          # test
        };

        signing = {
          signByDefault = true;
          format = "ssh";
          key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        };
      };

      delta = {
        enable = true;
        package = pkgs.unstable.delta;
        options = {
          line-numbers = true;
          side-by-side = true;
          diff-so-fancy = true;
          navigate = true;
        };
      };

      gh-dash = {
        enable = false;
        package = pkgs.unstable.gh-dash;
      };
    };

    home.packages = with pkgs.unstable; [
      gh
      serie
    ];

    programs.zsh.zsh-abbr.abbreviations = shellAliases;
  };
}
